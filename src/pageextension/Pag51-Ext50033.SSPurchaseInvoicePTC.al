//Added PTC as this is existing in BIR pac

pageextension 50033 "SS Purchase Invoice PTC" extends "Purchase Invoice"  //51 
{
    layout
    {
        modify(Control1900383207)
        {
            Visible = true;
        }
    }
}
