xmlport 50005 "Import Customer and Inv. Old"
{
    Caption = 'Import Customer and Invoice';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Customer and Invoice Staging"; "Customer and Invoice Staging")
            {
                XmlName = 'Import';
                fieldelement(f1; "Customer and Invoice Staging".Sequence)
                {
                }
                fieldelement(f2; "Customer and Invoice Staging"."Invoice Date")
                {
                }
                fieldelement(f3; "Customer and Invoice Staging"."Order Increment Id")
                {
                }
                fieldelement(f4; "Customer and Invoice Staging"."Customer Id")
                {
                }
                fieldelement(f5; "Customer and Invoice Staging"."Customer Name")
                {
                }
                fieldelement(f6; "Customer and Invoice Staging"."Item No.")
                {
                }
                fieldelement(f7; "Customer and Invoice Staging".Quantity)
                {
                }
                fieldelement(f8; "Customer and Invoice Staging"."Unit Price")
                {
                }
                fieldelement(f9; "Customer and Invoice Staging".Amount)
                {
                }
                fieldelement(f10; "Customer and Invoice Staging"."Integration Currency code")
                {
                }
                fieldelement(f11; "Customer and Invoice Staging"."Shipped From")
                {
                }
                fieldelement(f12; "Customer and Invoice Staging"."Exchange Rate")
                {
                }
                fieldelement(f13; "Customer and Invoice Staging"."Country Code")
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