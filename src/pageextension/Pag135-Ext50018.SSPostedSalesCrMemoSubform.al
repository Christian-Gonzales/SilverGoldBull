pageextension 50018 "SS Posted Sales Cr.MemoSubform" extends "Posted Sales Cr. Memo Subform"  //135
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
