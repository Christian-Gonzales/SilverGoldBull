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
                fieldelement(ff6; "Customer and Invoice Staging".Type)
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
                //fieldelement(f11; "Customer and Invoice Staging"."Shipped From")
                //{
                //    trigger OnAfterAssignField()
                //   begin
                //       if "Customer and Invoice Staging"."Gen. Product Posting Group" = '' then
                //           "Customer and Invoice Staging".Validate("Item No.");
                //   end;
                //}
                //fieldelement(f13; "Customer and Invoice Staging"."Country Code")
                //{
                //}
                //fieldelement(f12; "Customer and Invoice Staging"."Exchange Rate")
                //{
                //}
                //fieldelement(is_long_term_hold; "Customer and Invoice Staging"."No Mapping")
                //{
                //}
                //>>PTC001  //S is Column
                fieldelement(S1; "Customer and Invoice Staging"."PNR No.")
                {
                }
                fieldelement(T1; "Customer and Invoice Staging"."Booking Ref. No")
                {
                }
                fieldelement(U1; "Customer and Invoice Staging"."Passenger Name")
                {
                }

                fieldelement(V1; "Customer and Invoice Staging"."WHT Bus. Posting Group")
                {
                }
                fieldelement(W1; "Customer and Invoice Staging"."WHT Product Posting Group")
                {
                }
                fieldelement(X1; "Customer and Invoice Staging"."Client Type Code(Dimension)")
                {
                }
                fieldelement(Y1; "Customer and Invoice Staging"."Cost Category (Dimension)")
                {
                }
                fieldelement(Z1; "Customer and Invoice Staging"."Cost Center (Dimension)")
                {
                }
                fieldelement(AA; "Customer and Invoice Staging"."Office Location (Dimension)")
                {
                }
                fieldelement(AB; "Customer and Invoice Staging"."Principal (Dimension)")
                {
                }
                fieldelement(AC; "Customer and Invoice Staging"."Product Type (Dimension)")
                {
                }
                fieldelement(AD; "Customer and Invoice Staging"."Profit Center (Dimension)")
                {
                }
                fieldelement(AE; "Customer and Invoice Staging"."SF Code (Dimension)")
                {
                }
                fieldelement(AF; "Customer and Invoice Staging"."Test Code (Dimension)")
                {
                }
                fieldelement(AG; "Customer and Invoice Staging"."Transact Type (Dimension)")
                {
                }
                fieldelement(AH; "Customer and Invoice Staging"."Vessel (Dimension)")
                {
                }
                //<<PTC001

                trigger OnBeforeInsertRecord()
                var
                    FaultArea: Record "Fault Area";
                    SymptCode: Record "Symptom Code";
                begin
                    "Customer and Invoice Staging"."No Mapping" := '';
                end;


                trigger OnAfterInitRecord()
                var
                    myInt: Integer;
                begin
                    if not HeaderSkipped then begin
                        HeaderSkipped := true;
                        CurrXmlPort.Skip;
                        exit;
                    end;

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
    var
        HeaderSkipped: Boolean;
}

