tableextension 50010 "DirecDebitCollectionEntry" extends "Direct Debit Collection Entry"  //1208
{
    fields
    {

        field(50000; "Applies-to Entry Ext. Doc. No."; Code[35])
        {
            Caption = 'Applies-to Entry External Document No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Cust. Ledger Entry"."External Document No." where("Entry No." = field("Applies-to Entry No.")));

        }
    }
    procedure SetTodayAsTransferDateForOverdueEnries2()
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
    begin
        DirectDebitCollectionEntry.SetRange("Direct Debit Collection No.", "Direct Debit Collection No.");
        DirectDebitCollectionEntry.SetRange(Status, DirectDebitCollectionEntry.Status::New);
        DirectDebitCollectionEntry.SetFilter("Transfer Date", '<%1', Today());
        if DirectDebitCollectionEntry.FindSet(true) then
            repeat
                DirectDebitCollectionEntry.Validate("Transfer Date", Today());
                DirectDebitCollectionEntry.Modify(true);
                Codeunit.Run(Codeunit::"SEPA DD-Check Line All Curr.", DirectDebitCollectionEntry);
            until DirectDebitCollectionEntry.Next() = 0;
    end;

    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
}