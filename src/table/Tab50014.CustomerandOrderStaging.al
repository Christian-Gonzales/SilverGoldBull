table 50014 "Customer and Order Staging"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(10; Sequence; Integer)
        {
        }
        field(15; "Order Date"; Date)
        {
        }
        field(20; "Order Increment Id"; Code[20])
        {
        }
        field(25; "Customer Id"; Code[20])
        {
        }
        field(30; "Customer Name"; Text[100])
        {
        }
        field(35; "Item No."; Text[50])
        {
        }
        field(40; Quantity; Decimal)
        {
        }
        field(45; "Unit Price"; Decimal)
        {
        }
        field(50; Amount; Decimal)
        {
        }
        field(55; "Integration Currency code"; Code[10])
        {
        }
        field(60; "Shipped From"; Code[10])
        {
        }
        field(65; "Exchange Rate"; Decimal)
        {
            DecimalPlaces = 0 : 4;
        }
        field(70; "Country Code"; Code[20])
        {
        }
        field(100; "Date Imported"; DateTime)
        {
            Editable = false;
        }
        field(101; "Imported By"; Text[60])
        {
            Editable = false;
        }
        field(105; Regenerated; Boolean)
        {
        }
        field(106; "Regenerated from Entry No."; Integer)
        {
            Editable = false;
        }
        field(110; Processed; Boolean)
        {
            Editable = false;
        }
        field(111; "Date Processed"; DateTime)
        {
            Editable = false;
        }
        field(112; "Processed By"; Text[60])
        {
            Editable = false;
        }
        field(115; "Has Error"; Boolean)
        {
        }
        field(116; "Error 1"; Boolean)
        {
        }
        field(117; "Error 2"; Boolean)
        {
        }
        field(118; "Error 3"; Boolean)
        {
        }
        field(119; "Error 4"; Boolean)
        {
        }
        field(120; "Error Message"; Text[250])
        {
            Editable = false;
        }
        field(121; "Quantity Shipped"; Decimal)
        {
        }
        field(122; LTH; Boolean)
        {
        }
        field(123; LTHSHIP; Boolean)
        {
        }
        field(124; "Shipment Id"; Text[35])
        {
        }
        field(125; "Shipment Date"; Date)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Order Increment Id")
        {
        }
        key(Key3; "Shipped From", Processed)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Imported By" := USERID;
        "Date Imported" := CURRENTDATETIME;
    end;
}