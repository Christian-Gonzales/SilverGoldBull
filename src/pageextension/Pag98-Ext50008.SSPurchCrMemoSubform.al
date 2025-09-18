pageextension 50008 "SS Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform"  //98
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
