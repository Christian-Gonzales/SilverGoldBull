pageextension 50016 "SS Posted Purch.Cr.MemoSubform" extends "Posted Purch. Cr. Memo Subform"  //141
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
