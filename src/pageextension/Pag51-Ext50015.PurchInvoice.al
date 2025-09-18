pageextension 50015 "PurchInvoice" extends "Purchase Invoice"  //51
{
    layout
    {
        addbefore("Currency Code")
        {
            field("Posting No."; "Posting No.")
            {
                ApplicationArea = All;
            }
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}