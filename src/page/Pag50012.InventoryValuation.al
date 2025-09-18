page 50012 "Inventory Valuation"
{
    ApplicationArea = All;
    Caption = 'Inventory Valuation';
    PageType = List;
    SourceTable = "Item";
    UsageCategory = Lists;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Costing Method"; Rec."Costing Method")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Invoiced Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost Calc")
                {
                    ApplicationArea = All;
                }
                field("Inventory Value"; Rec."Cost Amount (Actual)")
                {
                    ApplicationArea = All;
                }
                field("Date Filter"; Rec."Date Filter")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ILE: Record "Item Ledger Entry";
    begin
        CLEAR(UnitCost);
        CLEAR(RemainingAmount);
        CLEAR(InventoryValue);
        Rec.PopulateUnitCostCalc;

        Rec.CalcFields("Remaining Quantity", "Cost Amount (Actual)");
        if Rec."Remaining Quantity" <> 0 then
            UnitCost := Rec."Cost Amount (Actual)" / Rec."Remaining Quantity";
    end;

    trigger OnOpenPage()
    var
        Item: Record Item;
    begin
        Item.RESET;
        if Item.Find('-') then
            repeat
                Rec.Init;
                Rec.TransferFields(Item);
                Rec.Insert();
            until Item.Next() = 0;

        Rec.SetFilter("Cost Amount (Actual)", '<>%1', 0);
        if Rec.FindFirst() Then;
    end;

    var
        RemainingAmount: Decimal;
        InventoryValue: Decimal;
        UnitCost: Decimal;
}
