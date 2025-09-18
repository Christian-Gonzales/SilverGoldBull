table 50001 "Purchase Invoice Staging"
{
    // SGB002  YD  20151120  Add fields  105 and 106

    DataPerCompany = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(10; "Date Received"; Date)
        {
        }
        field(15; "Seller Id"; Code[20])
        {
        }
        field(20; Supplier; Text[100])
        {
        }
        field(25; Contract; Code[20])
        {
        }
        field(28; "Metal Type"; Code[20])
        {
            TableRelation = "Metal Type";
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                MetalType: Record "Metal Type";
            begin
                if MetalType.Get("Metal Type") then begin
                    "Gen. Product Posting Group" := MetalType."Gen. Product Posting Group";
                    "Inventory Posting Group" := MetalType."Inventory Posting Group";
                end;
            end;
        }
        field(30; "Item No."; Text[50])
        {
            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." <> '' then begin
                    Item.Reset();
                    Item.SetRange("Integration Item", "Item No.");
                    if Item.FindFirst() then begin
                        "Base Unit of Measure" := Item."Base Unit of Measure";
                        "Gen. Product Posting Group" := Item."Gen. Prod. Posting Group";
                        "Inventory Posting Group" := Item."Inventory Posting Group";
                    end;
                end;
            end;
        }
        field(32; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(33; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            TableRelation = "Gen. Product Posting Group".Code;
        }
        field(34; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group".Code;
        }
        field(35; Description; Text[100])
        {
        }
        field(40; Quantity; Decimal)
        {
        }
        field(45; Cost; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(50; "Unit Cost"; Decimal)
        {
        }
        field(52; SubTotal; Decimal)
        {
        }
        field(55; "Integration Currency code"; Code[10])
        {
        }
        field(60; "Purchase From"; Code[10])
        {
        }
        field(65; "Exchange Rate"; Decimal)
        {
            DecimalPlaces = 0 : 4;
        }
        field(70; Destination; Text[100])
        {
        }
        field(80; "SKU"; Text[100])
        {
            Caption = 'SKU';
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
        field(121; "Error 5"; Boolean)
        {
        }
        field(122; "Receiving Date"; Date)
        {
        }
        field(123; "Receiving Id"; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
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

        if Rec."Base Unit of Measure" = '' then
            Rec.Validate("Base Unit of Measure", 'OZ');
    end;
}

