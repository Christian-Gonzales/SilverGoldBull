pageextension 50029 "CustLedgerEntryExt" extends "Customer Ledger Entries"  //25
{

    actions
    {
        addafter(ReverseTransaction)
        {
            action(SinglePaymentAppl)
            {
                ApplicationArea = All;
                Caption = 'Auto Apply Payment';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ApplyEntries;

                trigger OnAction()
                var
                    CustLedgerEntries: Record "Cust. Ledger Entry";
                    CustLedgerEntries1: Record "Cust. Ledger Entry";
                    lCRAmount: Decimal;
                begin
                    TestField("External Document No.");
                    TestField("Document Type", Rec."Document Type"::Payment);
                    TotalApplyAmount := 0;
                    CalcFields("Remaining Amount");
                    lCRAmount := abs(Rec."Remaining Amount");
                    rec."Applies-to ID" := UserId;
                    rec."Applying Entry" := true;

                    CustLedgerEntries.Reset();
                    CustLedgerEntries.SetCurrentKey("Due Date");
                    CustLedgerEntries.SetRange("External Document No.", Rec."External Document No.");
                    CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                    CustLedgerEntries.SetRange(Open, true);
                    CustLedgerEntries.SetFilter("Customer No.", Rec."Customer No.");
                    if CustLedgerEntries.Findset() then
                        repeat
                            if lCRAmount > 0 then begin
                                CustLedgerEntries.CalcFields("Remaining Amount");
                                if CustLedgerEntries."Remaining Amount" > lCRAmount then begin
                                    CustLedgerEntries1.Reset();
                                    CustLedgerEntries1.SetRange("Entry No.", CustLedgerEntries."Entry No.");
                                    if CustLedgerEntries1.FindFirst() then begin
                                        IF (CustLedgerEntries."Remaining Amount") <= (lCRAmount + CustLedgerEntries1."Max. Payment Tolerance") THEN
                                            lCRAmount := CustLedgerEntries."Remaining Amount";
                                        CustLedgerEntries1.VALIDATE("Amount to Apply", lCRAmount);
                                        CustLedgerEntries1.Modify();
                                        TotalApplyAmount += lCRAmount;
                                        lCRAmount := lCRAmount - CustLedgerEntries."Remaining Amount";
                                    end;
                                end else begin
                                    CustLedgerEntries1.Reset();
                                    CustLedgerEntries1.SetRange("Entry No.", CustLedgerEntries."Entry No.");
                                    if CustLedgerEntries1.FindFirst() then begin
                                        CustLedgerEntries1.VALIDATE("Amount to Apply", CustLedgerEntries."Remaining Amount");
                                        CustLedgerEntries1.Modify();

                                        TotalApplyAmount += CustLedgerEntries."Remaining Amount";
                                        lCRAmount := lCRAmount - CustLedgerEntries."Remaining Amount";
                                    end;
                                end;
                            end;
                        until CustLedgerEntries.Next() = 0;

                    CustLedgerEntries.Reset();
                    CustLedgerEntries.SetRange("External Document No.", Rec."External Document No.");
                    CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                    CustLedgerEntries.SetFilter("Amount to Apply", ' <> %1', 0);
                    CustLedgerEntries.SetFilter("Customer No.", Rec."Customer No.");
                    If CustLedgerEntries.FindSet() then begin
                        CustLedgerEntries.ModifyAll("Applies-to ID", UserId); //SSLT pOrderIncID
                        Rec."Amount to Apply" := -TotalApplyAmount;
                        Rec.Modify();
                        PostDirectApplication(CustLedgerEntries);
                        Message('Complete');
                    end;
                end;
            }
            action(MultiplePaymentAppl)
            {
                ApplicationArea = All;
                Caption = 'Multiple Payment Application';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ApplyEntries;

                trigger OnAction()
                var
                    MultPayment: Codeunit "Multiple Payment Application";
                begin
                    clear(MultPayment);
                    MultPayment.Run();
                    Message('Complete');
                    CurrPage.Update();
                end;
            }
        }
    }
    var
        PostingDone: Boolean;
        Text002: Label 'You must select an applying entry before you can post the application.';
        Text012: Label 'The application was successfully posted.';
        Text013: Label 'The %1 entered must not be before the %1 on the %2.';
        TotalApplyAmount: Decimal;

    local procedure PostDirectApplication(var cle: Record "Cust. Ledger Entry")
    var
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        PostApplication: Page "Post Application";
        Applied: Boolean;
        ApplicationDate: Date;
        NewApplicationDate: Date;
        NewDocumentNo: Code[20];
        IsHandled: Boolean;
        AUParameters: Record "Apply Unapply Parameters" temporary;
    begin
        cle.get("Entry No.");

        if Rec."Entry No." <> 0 then begin
            ApplicationDate := CustEntryApplyPostedEntries.GetApplicationDate(Rec);

            //PostApplication.SetValues("Document No.", ApplicationDate);  // Replaced by procedure SetParameters()

            AUParameters.CopyFromCustLedgEntry(Rec);
            AUParameters."Posting Date" := ApplicationDate;
            PostApplication.SetParameters(AUParameters);

            //Applied := CustEntryApplyPostedEntries.Apply(cle, "Document No.", ApplicationDate);  //Replaced by W1 implementation of Apply()
            Applied := CustEntryApplyPostedEntries.Apply(cle, AUParameters);





            if Applied then begin
                //Message(Text012);
                PostingDone := true;
                //CurrPage.Close;
            end;
        end else
            Error(Text002);
    end;
}