table 50000 "Customer and Invoice Staging"
{
    // SGB002  YD  20151120  Add fields  105 and 106
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
        field(15; "Invoice Date"; Date)
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
        field(33; "Metal Type"; Code[20])
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

        field(35; "Item No."; Text[50])
        {
            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
                Item: Record Item;
            begin
                if "Item No." <> '' then begin
                    CompanyInfo.Get;
                    if CompanyInfo."Shipped From" <> "Shipped From" then
                        Item.ChangeCompany(GetCompanyName("Shipped From"));

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
        field(36; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(37; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            TableRelation = "Gen. Product Posting Group".Code;
        }
        field(38; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group".Code;
        }
        field(39; Description; Text[100])
        {
            Caption = 'Description';
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
        field(121; "External Document No."; Code[35])
        {
            DataClassification = ToBeClassified;
        }
        field(122; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(123; "Shipment Increment Id"; Code[20])
        {
        }
        field(130; "No Mapping"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        //>>PTC001
        field(230; "PNR No."; code[30])
        {
            DataClassification = ToBeClassified;

        }
        field(231; "Booking Ref. No"; code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(232; "Passenger Name"; text[100])
        {
            DataClassification = ToBeClassified;

        }

        field(233; "WHT Bus. Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(234; "WHT Product Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(250; "Client Type Code(Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(251; "Cost Category (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(252; "Cost Center (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(253; "Office Location (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(254; "Principal (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(255; "Product Type (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(256; "Profit Center (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(257; "SF Code (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(258; "Test Code (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(259; "Transact Type (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(260; "Vessel (Dimension)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        //<<PTC001
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
        key(Key4; "Shipment Increment Id")
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
            Rec.Validate("Base Unit of Measure", 'PCS');//xtn
    end;

    local procedure GetCompanyName(ShippedFrom: Code[20]): Text[30]
    var
        Companies: Record Company;
        CompanyInfo: Record "Company Information";
    begin
        Companies.Reset();
        if Companies.FindFirst() then
            repeat
                CompanyInfo.Reset();
                CompanyInfo.ChangeCompany(Companies.Name);
                CompanyInfo.FindFirst();
                if CompanyInfo."Active Shipped From" then
                    if CompanyInfo."Shipped From" = ShippedFrom then
                        exit(Companies.Name);
            until Companies.Next() = 0;
    end;

    var
        cust: Record "Cust. Ledger Entry";
}

