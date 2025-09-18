pageextension 50027 "SalesOrderExt" extends "Sales Order"  //42
{
    layout
    {
        addafter("Work Description")
        {
            field("Created from Integration"; "Created from Integration")
            {
                Editable = false;
                ApplicationArea = all;
            }
            // field(LTH; LTH)
            // {
            //     Editable = false;
            //     //ApplicationArea = all;
            // }
            // field(LTHSHIP; LTHSHIP)
            // {
            //     Editable = false;
            //     //ApplicationArea = all;
            // }
        }
    }
}