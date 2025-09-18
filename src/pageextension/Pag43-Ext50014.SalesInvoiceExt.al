pageextension 50014 "SalesInvoiceExt" extends "Sales Invoice"  //43
{
    layout
    {
        addafter("Location Code")
        {
            field("Posting No."; "Posting No.")
            {
                Editable = true;
                ApplicationArea = all;
            }
        }


    }


}