pageextension 50012 "VendorList" extends "Vendor List"  //27
{


    actions
    {
        // Add changes to page actions here
        modify("Ledger E&ntries")
        {
            ApplicationArea = all;
        }
    }

    var
        myInt: Integer;
}