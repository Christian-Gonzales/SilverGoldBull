xmlport 50006 "Import Purchase Invoice v2"
{
    Caption = 'Import Purchase Invoice v2';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Purchase Invoice Staging"; "Purchase Invoice Staging")
            {
                XmlName = 'Import';
                fieldelement(f1; "Purchase Invoice Staging"."Receiving Date")
                {
                }
                fieldelement(f2; "Purchase Invoice Staging"."Date Received")
                {
                }
                fieldelement(f3; "Purchase Invoice Staging"."Seller Id")
                {
                }
                fieldelement(f4; "Purchase Invoice Staging".Supplier)
                {
                }
                fieldelement(f5; "Purchase Invoice Staging"."Receiving Id")
                {
                }
                fieldelement(f6; "Purchase Invoice Staging".Contract)
                {
                }
                fieldelement(metal_type; "Purchase Invoice Staging"."Metal Type")
                {
                }
                fieldelement(f7; "Purchase Invoice Staging"."Item No.")
                {
                }
                fieldelement(SKU; "Purchase Invoice Staging".SKU)
                {
                }
                fieldelement(f8; "Purchase Invoice Staging".Description)
                {
                }
                fieldelement(f9; "Purchase Invoice Staging".Quantity)
                {
                }
                fieldelement(f10; "Purchase Invoice Staging".Cost)
                {
                }
                fieldelement(f11; "Purchase Invoice Staging".SubTotal)
                {
                }
                fieldelement(f12; "Purchase Invoice Staging"."Exchange Rate")
                {
                }
                fieldelement(f13; "Purchase Invoice Staging"."Integration Currency code")
                {
                }
                fieldelement(f14; "Purchase Invoice Staging"."Purchase From")
                {
                }
                textelement(customer_orders)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    CurrExchRate: Record "Currency Exchange Rate";
                    Currency: Record Currency;
                    FromDate: date;
                    isFound: Boolean;
                begin

                    isFound := false;
                    if "Purchase Invoice Staging"."Purchase From" = 'US' then begin
                        if "Purchase Invoice Staging"."Integration Currency code" = 'CAD' then begin
                            "Purchase Invoice Staging"."Has Error" := true;
                            "Purchase Invoice Staging"."Error Message" := 'Check Magento Order'
                        end else
                            "Purchase Invoice Staging"."Exchange Rate" := 1;

                    end else
                        if "Purchase Invoice Staging"."Purchase From" = 'CA' then begin
                            if ("Purchase Invoice Staging"."Integration Currency code" = 'USD') and (("Purchase Invoice Staging"."Exchange Rate" = 0) or ("Purchase Invoice Staging"."Exchange Rate" = 1)) then begin
                                if Currency.get("Purchase Invoice Staging"."Integration Currency code") then begin
                                    FromDate := CalcDate('-1W', "Purchase Invoice Staging"."Receiving Date");
                                    Clear(CurrExchRate);
                                    CurrExchRate.SetRange("Currency Code", Currency.Code);
                                    CurrExchRate.SetRange("Starting Date", FromDate, "Purchase Invoice Staging"."Receiving Date");
                                    if CurrExchRate.FindLast() then
                                        repeat
                                            IF CurrExchRate."Exchange Rate Amount" <> 0 THEN begin
                                                "Purchase Invoice Staging"."Exchange Rate" := CurrExchRate."Relational Exch. Rate Amount" / CurrExchRate."Exchange Rate Amount";
                                                isFound := true;
                                            end;
                                        until (CurrExchRate.Next() < 0) or isFound;
                                end;
                            end else
                                if "Purchase Invoice Staging"."Integration Currency code" = 'CAD' then begin
                                    "Purchase Invoice Staging"."Exchange Rate" := 1;
                                end;
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
        Currency: Record Currency;
}

