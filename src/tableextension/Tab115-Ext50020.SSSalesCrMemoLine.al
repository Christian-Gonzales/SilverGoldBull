tableextension 50020 "SS Sales Cr.Memo Line" extends "Sales Cr.Memo Line"  //115
{
    fields
    {
        field(50000; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Cr.Memo Header"."External Document No." where("No." = field("Document No.")));
        }
        field(50001; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Cr.Memo Header"."Currency Factor" where("No." = field("Document No.")));
        }
        field(50005; "SKU"; Text[100])
        {
            Caption = 'SKU';
            DataClassification = CustomerContent;
        }
    }
}
