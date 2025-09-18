page 50015 "Metal Type"
{
    ApplicationArea = All;
    Caption = 'Metal Type';
    PageType = List;
    SourceTable = "Metal Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Gen. Product Posting Group"; Rec."Gen. Product Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Product Posting Group field.';
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field.';
                }
            }
        }
    }
}
