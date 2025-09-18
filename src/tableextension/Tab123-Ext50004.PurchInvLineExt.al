tableextension 50004 "Purch. Inv. Line Ext" extends "Purch. Inv. Line"  //123
{
    fields
    {
        field(50000; "Integration Receiving ID"; Code[20])
        {
            Caption = 'Integration Receiving ID';
            DataClassification = CustomerContent;
        }
        field(50005; "SKU"; Text[100])
        {
            Caption = 'SKU';
            DataClassification = CustomerContent;
        }
    }
}
