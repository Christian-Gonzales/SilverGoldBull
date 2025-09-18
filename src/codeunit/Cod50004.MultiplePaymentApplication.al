codeunit 50004 "Multiple Payment Application"
{
    trigger OnRun()
    begin
        clear(CLE);
        CLE.SetCurrentKey("Posting Date");
        CLE.SetRange("Document Type", CLE."Document Type"::Payment);
        CLE.SetRange(Open, true);
        CLE.Setfilter("External Document No.", '<>%1', '');

        if CLE.FindSet() then
            repeat

                TotalApplyAmount := 0;
                lCRAmount := 0;
                CLE.CalcFields("Remaining Amount");
                lCRAmount := abs(CLE."Remaining Amount");
                CLE."Applies-to ID" := CLE."Document No.";
                CLE."Applies-to ID" := USERID;
                CLE."Applying Entry" := true;

                CustLedgerEntries.Reset();
                CustLedgerEntries.SetCurrentKey("Due Date");
                CustLedgerEntries.SetRange("External Document No.", CLE."External Document No.");
                CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                CustLedgerEntries.SetRange(Open, true);
                CustLedgerEntries.SetFilter("Customer No.", CLE."Customer No.");
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
                CustLedgerEntries.SetRange("External Document No.", CLE."External Document No.");
                CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                CustLedgerEntries.SetFilter("Amount to Apply", ' <> %1', 0);
                CustLedgerEntries.SetFilter("Customer No.", CLE."Customer No.");
                If CustLedgerEntries.FindSet() then begin
                    CustLedgerEntries.ModifyAll("Applies-to ID", USERID); //SSLT pOrderIncID
                    CLE."Amount to Apply" := -TotalApplyAmount;
                    CLE.Modify();
                    PostDirectApplication(CustLedgerEntries);

                end;
            until CLE.Next() = 0;
    end;

    var
        Customer: Record Customer;
        CLE: Record "Cust. Ledger Entry";
        CustLedgerEntries: Record "Cust. Ledger Entry";
        CustLedgerEntries1: Record "Cust. Ledger Entry";
        TotalApplyAmount: Decimal;
        lCRAmount: Decimal;
        PostingDone: Boolean;
        Text002: Label 'You must select an applying entry before you can post the application.';
        Text012: Label 'The application was successfully posted.';
        Text013: Label 'The %1 entered must not be before the %1 on the %2.';


    local procedure PostDirectApplication(var CustLedgEntry: Record "Cust. Ledger Entry")
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
        CustLedgEntry.get(CLE."Entry No.");

        if CLE."Entry No." <> 0 then begin
            ApplicationDate := CustEntryApplyPostedEntries.GetApplicationDate(CLE);

            //PostApplication.SetValues(CLE."Document No.", ApplicationDate);  // Replaced by procedure SetParameters()

            AUParameters.CopyFromCustLedgEntry(CLE);
            AUParameters."Posting Date" := ApplicationDate;
            PostApplication.SetParameters(AUParameters);

            //Applied := CustEntryApplyPostedEntries.Apply(CustLedgEntry, CLE."Document No.", ApplicationDate);  //Replaced by W1 implementation of Apply()
            Applied := CustEntryApplyPostedEntries.Apply(CustLedgEntry, AUParameters);

            if Applied then begin
                // Message(Text012);0
                PostingDone := true;
                //CurrPage.Close;
            end;
        end else
            Error(Text002);
    end;

    local procedure PostDirectApplication2(var CustLedgEntry: Record "Cust. Ledger Entry")
    var
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        PostApplication: Page "Post Application";
        Applied: Boolean;
        ApplicationDate: Date;
        NewApplicationDate: Date;
        NewDocumentNo: Code[20];
        IsHandled: Boolean;
        L_CLE: Record "Cust. Ledger Entry";
        AUParameters: Record "Apply Unapply Parameters" temporary;
    begin
        L_CLE.get(CustLedgEntry."Entry No.");

        if L_CLE."Entry No." <> 0 then begin
            ApplicationDate := CustEntryApplyPostedEntries.GetApplicationDate(L_CLE);

            //PostApplication.SetValues(L_CLE."Document No.", ApplicationDate);  // Replaced by procedure SetParameters()

            AUParameters.CopyFromCustLedgEntry(L_CLE);
            AUParameters."Posting Date" := ApplicationDate;
            PostApplication.SetParameters(AUParameters);

            //Applied := CustEntryApplyPostedEntries.Apply(L_CLE, L_CLE."Document No.", ApplicationDate);  //Replaced by W1 implementation of Apply()
            Applied := CustEntryApplyPostedEntries.Apply(L_CLE, AUParameters);

            if Applied then begin
                // Message(Text012);
                PostingDone := true;
                //CurrPage.Close;
            end;
        end else
            Error(Text002);
    end;

    procedure SOSIAutoApplyPostPayment(SalesHeader: Record "Sales Header"; var CustLedgEntry: Record "Cust. Ledger Entry")
    var
        L_CLE: Record "Cust. Ledger Entry";
        L_SalesSetup: Record "Sales & Receivables Setup";
        FromAmount: Decimal;
        ToAmount: Decimal;
        PlusExp: Text[10];
        MinusExp: Text[10];
        FromDate: Date;
        ToDate: Date;
        L_ExtDocNoFilter: Code[50];

    begin
        L_SalesSetup.get;
        CustLedgEntry.CalcFields("Remaining Amount");
        FromAmount := 0;
        ToAmount := 0;
        SalesHeader.CalcFields(Amount);
        FromAmount := Round(CustLedgEntry."Remaining Amount", 1, '<');
        ToAmount := FromAmount + L_SalesSetup."SO/SI Tolerance Amount";
        FromAmount := FromAmount - L_SalesSetup."SO/SI Tolerance Amount";
        PlusExp := FORMAT(L_SalesSetup."SO/SI Tolerance Day") + 'D';
        MinusExp := FORMAT((-1) * L_SalesSetup."SO/SI Tolerance Day") + 'D';
        FromDate := CalcDate(MinusExp, SalesHeader."Posting Date");
        ToDate := CalcDate(PlusExp, SalesHeader."Posting Date");

        L_ExtDocNoFilter := '**';
        if L_SalesSetup."Apply to Ext. Doc. No." then
            if SalesHeader."External Document No." <> '' then
                L_ExtDocNoFilter := SalesHeader."External Document No."
            else
                exit;


        clear(L_CLE);
        L_CLE.SetCurrentKey("Posting Date");
        L_CLE.SetRange("Document Type", L_CLE."Document Type"::Payment);
        L_CLE.SetRange(Open, true);
        L_CLE.Setfilter("External Document No.", '%1', L_ExtDocNoFilter);
        L_CLE.setrange("Posting Date", FromDate, ToDate);
        L_CLE.CalcFields("Remaining Amount");
        L_CLE.SetRange("Remaining Amount", -ToAmount, -FromAmount);
        if L_CLE.FindSet() then
            repeat

                TotalApplyAmount := 0;
                lCRAmount := 0;
                L_CLE.CalcFields("Remaining Amount");
                lCRAmount := abs(L_CLE."Remaining Amount");
                L_CLE."Applies-to ID" := L_CLE."Document No.";
                L_CLE."Applies-to ID" := USERID;
                L_CLE."Applying Entry" := true;

                CustLedgerEntries.Reset();
                CustLedgerEntries.SetCurrentKey("Due Date");
                CustLedgerEntries.SetRange("Entry No.", CustLedgEntry."Entry No.");
                CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                CustLedgerEntries.SetRange(Open, true);
                CustLedgerEntries.SetFilter("Customer No.", CustLedgEntry."Customer No.");
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
                CustLedgerEntries.SetRange("Entry No.", CustLedgEntry."Entry No.");
                CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                CustLedgerEntries.SetFilter("Amount to Apply", ' <> %1', 0);
                CustLedgerEntries.SetFilter("Customer No.", L_CLE."Customer No.");
                If CustLedgerEntries.FindSet() then begin
                    CustLedgerEntries.ModifyAll("Applies-to ID", USERID); //SSLT pOrderIncID
                    L_CLE."Amount to Apply" := -TotalApplyAmount;
                    L_CLE.Modify();
                    PostDirectApplication2(L_CLE);

                end;
            until L_CLE.Next() = 0;
    end;
}