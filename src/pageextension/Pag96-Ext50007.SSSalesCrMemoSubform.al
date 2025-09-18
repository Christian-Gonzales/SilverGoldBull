pageextension 50007 "SS Sales Cr. Memo Subform" extends "Sales Cr. Memo Subform"  //96
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
