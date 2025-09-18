pageextension 50013 "ItemList" extends "Item List"  //31
{
    layout
    {
        addafter("Unit Price")
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

}