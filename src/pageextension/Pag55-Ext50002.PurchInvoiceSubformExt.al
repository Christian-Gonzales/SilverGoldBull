pageextension 50002 "Purch. Invoice Subform Ext" extends "Purch. Invoice Subform"  //55
{
    layout
    {
        addlast(PurchDetailLine)
        {
            field("Integration Receiving ID"; Rec."Integration Receiving ID")
            {
                ApplicationArea = All;
            }
        }
        addafter(Description)
        {
            field("SKU"; Rec."SKU")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the To SKU field.';
            }
        }
    }
}
