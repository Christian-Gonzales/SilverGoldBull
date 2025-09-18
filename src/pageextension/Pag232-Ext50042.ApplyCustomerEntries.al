pageextension 50042 "Apply Customer Entries" extends "Apply Customer Entries"  //232
{
    layout
    {
        modify("External Document No.")
        {
            Visible = true;
        }
        moveafter("Document No."; "External Document No.")
    }
}
