xmlport 50023 "PaymntType"
{

    schema
    {
        textelement(root)
        {
            tableelement("Payment Type Mapping"; "Payment Type Mapping")
            {
                XmlName = 'paymentType';
                fieldelement(a; "Payment Type Mapping"."Payment Type")
                {
                }
                fieldelement(s; "Payment Type Mapping"."NAV Type")
                {
                }
                fieldelement(d; "Payment Type Mapping"."NAV No.")
                {
                }
                fieldelement(f; "Payment Type Mapping"."Integration Currency Code")
                {
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }
    trigger OnPostXmlPort()
    begin
        Message('Done!');
    end;
}

