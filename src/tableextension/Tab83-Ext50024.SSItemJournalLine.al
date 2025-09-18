tableextension 50024 "SS Item Journal Line" extends "Item Journal Line"  //83
{
    fields
    {
        field(50005; "SKU"; Text[100])
        {
            Caption = 'SKU';
            DataClassification = CustomerContent;
        }
    }
}
