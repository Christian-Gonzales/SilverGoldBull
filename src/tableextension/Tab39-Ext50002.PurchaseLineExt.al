tableextension 50002 "Purchase Line Ext" extends "Purchase Line"  //39
{
    fields
    {
        field(50000; "Integration Receiving ID"; Code[20])
        {
            Caption = 'Integration Receiving ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50005; "SKU"; Text[100])
        {
            Caption = 'SKU';
            DataClassification = CustomerContent;
        }
    }
}
