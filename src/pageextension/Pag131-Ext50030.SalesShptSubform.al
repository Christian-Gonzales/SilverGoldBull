pageextension 50030 "SalesShptSubform" extends "Posted Sales Shpt. Subform"  //131
{
    layout
    {
        addafter("Location Code")
        {
            field(LTH; LTH)
            {
                Editable = false;
                ApplicationArea = all;
            }
            field(LTHSHIP; LTHSHIP)
            {
                Editable = false;
                ApplicationArea = all;
            }
        }
        addafter("Shipment Date")
        {
            field("Shipment Id"; "Shipment Id")
            {
                Editable = false;
                ApplicationArea = all;
            }
        }
    }


}