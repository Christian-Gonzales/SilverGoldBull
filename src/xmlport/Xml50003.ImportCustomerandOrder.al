xmlport 50003 "Import Customer and Order"
{
    Caption = 'Import Customer and Order';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Customer and Order Staging"; "Customer and Order Staging")
            {
                XmlName = 'Import';
                fieldelement(f1; "Customer and Order Staging".Sequence)
                {
                }
                fieldelement(f2; "Customer and Order Staging"."Order Date")
                {
                }
                fieldelement(f3; "Customer and Order Staging"."Order Increment Id")
                {
                }
                fieldelement(f4; "Customer and Order Staging"."Customer Id")
                {
                }
                fieldelement(f5; "Customer and Order Staging"."Customer Name")
                {
                }
                fieldelement(f6; "Customer and Order Staging"."Item No.")
                {
                }
                fieldelement(f7; "Customer and Order Staging".Quantity)
                {
                }
                fieldelement(f8; "Customer and Order Staging"."Quantity Shipped")
                {
                }
                fieldelement(f9; "Customer and Order Staging".LTH)
                {
                }
                fieldelement(f10; "Customer and Order Staging".LTHSHIP)
                {
                }
                fieldelement(f11; "Customer and Order Staging"."Shipment Id")
                {
                }
                fieldelement(f12; "Customer and Order Staging"."Shipment Date")
                {
                }
                fieldelement(f13; "Customer and Order Staging"."Unit Price")
                {
                }
                fieldelement(f14; "Customer and Order Staging".Amount)
                {
                }
                fieldelement(f15; "Customer and Order Staging"."Integration Currency code")
                {
                }
                fieldelement(f16; "Customer and Order Staging"."Shipped From")
                {
                }
                fieldelement(f17; "Customer and Order Staging"."Exchange Rate")
                {
                }
                fieldelement(f18; "Customer and Order Staging"."Country Code")
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    FaultArea: Record "Fault Area";
                    SymptCode: Record "Symptom Code";
                begin
                end;
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
}

