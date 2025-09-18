pageextension 50003 "PostedPurchInvoiceSubform Ext" extends "Posted Purch. Invoice Subform"  //139
{
    layout
    {
        addlast(Control1)
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
