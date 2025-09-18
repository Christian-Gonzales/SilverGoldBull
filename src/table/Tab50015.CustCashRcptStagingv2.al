table 50015 "Cust Cash Rcpt Staging v2"
{
    DataPerCompany = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(20; "Customer Id"; Code[20])
        {
        }
        field(22; "Customer Name"; Text[100])
        {
        }
        field(25; "Order Increment Id"; Code[20])
        {
        }
        field(35; "Document No."; Text[50])
        {
        }
        field(37; "Payment Type"; Text[30])
        {
        }
        field(50; Amount; Decimal)
        {
        }
        field(55; "Integration Currency Code"; Code[10])
        {
        }
        field(56; "Posting Date"; Date)
        {
        }
        field(60; "Shipped From"; Code[10])
        {
        }
        field(65; "Exchange Rate"; Decimal)
        {
            DecimalPlaces = 0 : 4;
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
            Editable = true;
        }
        field(111; "Date Processed"; DateTime)
        {
            Editable = true;
        }
        field(112; "Processed By"; Text[60])
        {
            Editable = true;
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
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Customer Id")
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

