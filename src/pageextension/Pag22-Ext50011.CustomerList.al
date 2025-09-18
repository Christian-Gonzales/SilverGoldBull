pageextension 50011 "CustomerList" extends "Customer List"  //22
{


    actions
    {
        // Add changes to page actions here
        modify(CustomerLedgerEntries)
        {
            ApplicationArea = all;
        }

    }
}