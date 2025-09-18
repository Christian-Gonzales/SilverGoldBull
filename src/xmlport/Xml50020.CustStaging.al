xmlport 50020 "CustStaging"
{

    schema
    {
        textelement(root)
        {
            tableelement("Customer and Invoice Staging"; "Customer and Invoice Staging")
            {
                XmlName = 'CustStage';


                fieldelement(a; "Customer and Invoice Staging"."Entry No.")
                {
                }
                fieldelement(b; "Customer and Invoice Staging".Sequence)
                {
                }
                fieldelement(c; "Customer and Invoice Staging"."Invoice Date")
                {
                }
                fieldelement(d; "Customer and Invoice Staging"."Order Increment Id")
                {
                }
                fieldelement(e; "Customer and Invoice Staging"."Customer Id")
                {
                }
                fieldelement(f; "Customer and Invoice Staging"."Customer Name")
                {
                }
                fieldelement(g; "Customer and Invoice Staging"."Item No.")
                {
                }
                fieldelement(h; "Customer and Invoice Staging".Quantity)
                {
                }
                fieldelement(i; "Customer and Invoice Staging"."Unit Price")
                {
                }
                fieldelement(j; "Customer and Invoice Staging".Amount)
                {
                }
                fieldelement(k; "Customer and Invoice Staging"."Integration Currency code")
                {
                }
                fieldelement(l; "Customer and Invoice Staging"."Shipped From")
                {
                }
                fieldelement(m; "Customer and Invoice Staging"."Exchange Rate")
                {
                }
                fieldelement(n; "Customer and Invoice Staging"."Country Code")
                {
                }
                fieldelement(o; "Customer and Invoice Staging"."Date Imported")
                {
                }
                fieldelement(p; "Customer and Invoice Staging"."Imported By")
                {
                }
                fieldelement(q; "Customer and Invoice Staging".Regenerated)
                {
                }
                fieldelement(r; "Customer and Invoice Staging"."Regenerated from Entry No.")
                {
                }
                fieldelement(s; "Customer and Invoice Staging".Processed)
                {
                }
                fieldelement(t; "Customer and Invoice Staging"."Date Processed")
                {
                }
                fieldelement(df; "Customer and Invoice Staging"."Processed By")
                {
                }
                fieldelement(sd; "Customer and Invoice Staging"."Has Error")
                {
                }
                fieldelement(sd1; "Customer and Invoice Staging"."Error 1")
                {
                }
                fieldelement(ffd; "Customer and Invoice Staging"."Error 2")
                {
                }
                fieldelement(gf; "Customer and Invoice Staging"."Error 3")
                {
                }
                fieldelement(hg; "Customer and Invoice Staging"."Error 4")
                {
                }
                fieldelement(kj; "Customer and Invoice Staging"."Error Message")
                {
                }
                trigger OnBeforeInsertRecord()
                var
                    CustStaging: Record "Customer and Invoice Staging";
                begin
                    if CustStaging.get("Customer and Invoice Staging"."Entry No.") then
                        currXMLport.Skip();
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
    trigger OnPostXmlPort()
    begin
        Message('Done!');
    end;

}

