tableextension 50017 "Purchase Line Archive Ext" extends "Purchase Line Archive"  //5110
{
    fields
    {
        field(50000; "Integration Receiving ID"; Code[20])
        {
            Caption = 'Integration Receiving ID';
            DataClassification = CustomerContent;
        }
    }
}
