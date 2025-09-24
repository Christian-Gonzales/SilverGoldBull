pageextension 50006 "SS Sales Invoice Subform" extends "Sales Invoice Subform"  //47
{
    layout
    {
        addafter(Description)
        {
            field("SKU"; Rec."SKU")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the To SKU field.';
            }
        }
        //>>PTC001
        addafter("Qty. to Assign")
        {
            field("PNR No."; rec."PNR No.")
            {
                ApplicationArea = all;
            }
            field("Booking Ref. No"; rec."Booking Ref. No")
            {
                ApplicationArea = all;
            }
            field("Passenger Name"; rec."Passenger Name")
            {
                ApplicationArea = all;
            }
        }
        //<<PTC001
    }
}
