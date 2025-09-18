xmlport 50000 "Import Customer and Invoice"
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
                fieldelement(shipment_date; "Customer and Invoice Staging"."Shipment Date")
                {
                }
                fieldelement(f2; "Customer and Invoice Staging"."Invoice Date")
                {
                }
                fieldelement(shipment_increment_id; "Customer and Invoice Staging"."Shipment Increment Id")
                {
                }
                fieldelement(f3; "Customer and Invoice Staging"."Order Increment Id")
                {
                }
                //fieldelement(external_document_no; "Customer and Invoice Staging"."External Document No.")
                //{
                //    MinOccurs = Zero;
                //}
                fieldelement(f4; "Customer and Invoice Staging"."Customer Id")
                {
                }
                fieldelement(f5; "Customer and Invoice Staging"."Customer Name")
                {
                }
                fieldelement(metal_type; "Customer and Invoice Staging"."Metal Type")
                {
                }
                fieldelement(f6; "Customer and Invoice Staging"."Item No.")
                {
                }
                fieldelement(SKU; "Customer and Invoice Staging".SKU)
                {
                }
                fieldelement(description; "Customer and Invoice Staging".Description)
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
                //fieldelement(org_qty; "Customer and Invoice Staging"."No Mapping")
                //{
                //}
                //fieldelement(org_price_ea; "Customer and Invoice Staging"."No Mapping")
                //{
                //}
                //fieldelement(org_amount; "Customer and Invoice Staging"."No Mapping")
                //{
                //}
                fieldelement(f10; "Customer and Invoice Staging"."Integration Currency code")
                {
                }
                fieldelement(f11; "Customer and Invoice Staging"."Shipped From")
                {
                    trigger OnAfterAssignField()
                    begin
                        if "Customer and Invoice Staging"."Gen. Product Posting Group" = '' then
                            "Customer and Invoice Staging".Validate("Item No.");
                    end;
                }
                fieldelement(f13; "Customer and Invoice Staging"."Country Code")
                {
                }
                fieldelement(f12; "Customer and Invoice Staging"."Exchange Rate")
                {
                }
                //fieldelement(is_long_term_hold; "Customer and Invoice Staging"."No Mapping")
                //{
                //}

                trigger OnBeforeInsertRecord()
                var
                    FaultArea: Record "Fault Area";
                    SymptCode: Record "Symptom Code";
                begin
                    "Customer and Invoice Staging"."No Mapping" := '';
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

