pageextension 50009 "CompanyInformationCard" extends "Company Information"  //1
{
    layout
    {
        addafter("Industrial Classification")
        {
            field("Shipped From"; "Shipped From")
            {
                ApplicationArea = all;
            }
            field("Use Exchange Rate"; "Use Exchange Rate")
            {
                ApplicationArea = all;
            }
            field("Active Shipped From"; Rec."Active Shipped From")
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