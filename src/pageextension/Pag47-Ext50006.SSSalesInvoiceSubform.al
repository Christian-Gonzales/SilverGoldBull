pageextension 50006 "SS Sales Invoice Subform" extends "Sales Invoice Subform"  //47
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
