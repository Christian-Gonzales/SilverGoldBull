tableextension 50005 "ItemExt" extends Item  //27
{
    fields
    {
        field(50000; "Integration Item"; Code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Integration Unit';
            trigger OnValidate()
            var
                myInt: Integer;
            begin

                IF ("Search Description" = UPPERCASE(xRec.Description)) OR ("Search Description" = '') THEN
                    "Search Description" := Description;

                IF "Created From Nonstock Item" THEN BEGIN
                    NonstockItem.SETCURRENTKEY("Item No.");
                    NonstockItem.SETRANGE("Item No.", "No.");
                    IF NonstockItem.FINDFIRST THEN
                        IF NonstockItem.Description = '' THEN BEGIN
                            NonstockItem.Description := Description;
                            NonstockItem.MODIFY;
                        END;
                END;

            end;
        }
        field(50001; "Remaining Quantity"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE("Item No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Remaining Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50002; "Cost Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Cost Amount (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50003; "Invoiced Quantity"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Item No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Invoiced Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50004; "Unit Cost Calc"; Decimal)
        {
            Caption = 'Unit Cost Calc';
        }
        field(50005; "Remaining Quantity Calc"; Decimal)
        {
            Caption = 'Remaining Quantity Calc';
        }
        field(50006; "Inventory Value Calc"; Decimal)
        {
            Caption = 'Inventory Value Calc';
        }
    }

    procedure PopulateUnitCostCalc()
    begin
        if "Invoiced Quantity" <> 0 then
            "Unit Cost Calc" := "Cost Amount (Actual)" / "Invoiced Quantity";
    end;

    var
        myInt: Integer;
        nonstockitem: Record "Nonstock Item";
}