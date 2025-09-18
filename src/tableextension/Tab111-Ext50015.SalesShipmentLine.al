tableextension 50015 "SalesShipmentLine" extends "Sales Shipment Line"  //111
{
    fields
    {
        field(50000; LTH; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; LTHSHIP; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Shipment Id"; Text[35])
        {
            DataClassification = ToBeClassified;
        }

    }

}