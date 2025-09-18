tableextension 50021 "SS Item Ledger Entry" extends "Item Ledger Entry"  //32
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
