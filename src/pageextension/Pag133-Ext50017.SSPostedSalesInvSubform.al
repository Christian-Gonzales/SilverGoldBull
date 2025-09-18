pageextension 50017 "SS Posted Sales Inv. Subform" extends "Posted Sales Invoice Subform"  //133
{
    layout
    {
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
