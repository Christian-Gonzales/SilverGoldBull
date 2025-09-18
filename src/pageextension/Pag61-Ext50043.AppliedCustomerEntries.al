pageextension 50043 "Applied Customer Entries" extends "Applied Customer Entries"  //61
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
