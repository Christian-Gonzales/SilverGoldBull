tableextension 50018 "Return Shipment Line Ext" extends "Return Shipment Line"  //6651
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
