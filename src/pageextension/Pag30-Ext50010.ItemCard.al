pageextension 50010 "ItemCard" extends "Item Card"  //30
{
    layout
    {
        addafter("Description")
        {
            field("Integration Item"; "Integration Item")
            {
                ApplicationArea = all;
            }
        }
    }


    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}