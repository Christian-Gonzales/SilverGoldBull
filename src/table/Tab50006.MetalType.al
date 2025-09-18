table 50006 "Metal Type"
{
    Caption = 'Metal Type';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[150])
        {
            Caption = 'Description';
        }
        field(10; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            TableRelation = "Gen. Product Posting Group".Code;
        }
        field(11; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group".Code;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
