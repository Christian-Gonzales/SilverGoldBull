//Added PTC as this is existing in BIR pac
pageextension 50035 "SS Posted Purchase Invoice PTC" extends "Posted Purchase Invoice"  //138
{
    layout
    {
        modify(Control1900383207)
        {
            Visible = true;
        }
    }
}
