table 50005 "Item Transfer Staging"
{
    Caption = 'Item Transfer Staging';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; "From Item No."; Code[30])
        {
            Caption = 'From Item No.';
        }
        field(5; "From Item Description"; Text[100])
        {
            Caption = 'From Item Description';
        }
        field(6; "To Item No."; Code[30])
        {
            Caption = 'To Item No.';
            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "To Item No." <> '' then begin
                    Item.Reset();
                    Item.SetRange("Integration Item", "To Item No.");
                    if Item.FindFirst() then begin
                        "To Base Unit of Measure" := Item."Base Unit of Measure";
                        "To Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                        "To Inventory Posting Group" := Item."Inventory Posting Group";
                    end;
                end;
            end;
        }
        field(7; "To Item Description"; Text[100])
        {
            Caption = 'To Item Description';
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(9; "To Base Unit of Measure"; Code[10])
        {
            Caption = 'To Base Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(10; "To Metal Type"; Code[20])
        {
            Caption = 'To Metal Type';
            TableRelation = "Metal Type";
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                MetalType: Record "Metal Type";
            begin
                if MetalType.Get("To Metal Type") then begin
                    "To Gen. Prod. Posting Group" := MetalType."Gen. Product Posting Group";
                    "To Inventory Posting Group" := MetalType."Inventory Posting Group";
                end;
            end;
        }
        field(20; "To Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'To Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group".Code;
        }
        field(21; "To Inventory Posting Group"; Code[20])
        {
            Caption = 'To Inventory Posting Group';
            TableRelation = "Inventory Posting Group".Code;
        }
        field(30; "SKU"; Text[100])
        {
            Caption = 'SKU';
        }
        field(400; "Regenerated From Entry No."; Integer)
        {
            Caption = 'Regenerated From Entry No.';
        }
        field(500; "Date Imported"; DateTime)
        {
            Caption = 'Date Imported';
        }
        field(501; "Imported By"; Code[20])
        {
            Caption = 'Imported By';
        }
        field(502; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(503; "Date Processed"; DateTime)
        {
            Caption = 'Date Processed';
        }
        field(504; "Process By"; Code[20])
        {
            Caption = 'Process By';
        }
        field(505; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
        }
        field(506; "Document Has Error"; Boolean)
        {
            Caption = 'Document Has Error';
            FieldClass = FlowField;
            CalcFormula = exist("Item Transfer Staging" where("External Document No." = field("External Document No."), "Error Message" = filter(<> '')));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Imported By" := UserId;
        "Date Imported" := CurrentDateTime;

        if Rec."To Base Unit of Measure" = '' then
            Rec.Validate("To Base Unit of Measure", 'OZ');
    end;
}
