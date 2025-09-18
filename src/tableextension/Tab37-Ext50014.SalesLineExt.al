tableextension 50014 "SalesLineExt" extends "Sales Line"  //37
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
        field(50005; "SKU"; Text[100])
        {
            Caption = 'SKU';
            DataClassification = CustomerContent;
        }
    }

}