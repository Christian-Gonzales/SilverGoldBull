pageextension 50004 "Value Entries Ext" extends "Value Entries"  //5802
{
    layout
    {
        addlast(Control1)
        {
            field("Variant Code"; Rec."Variant Code")
            {
                ApplicationArea = All;
            }
        }
    }
}
