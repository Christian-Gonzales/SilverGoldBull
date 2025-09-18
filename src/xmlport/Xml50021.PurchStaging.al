xmlport 50021 "Purch Staging"
{

    schema
    {
        textelement(root)
        {
            tableelement("Purchase Invoice Staging"; "Purchase Invoice Staging")
            {
                XmlName = 'PurchStage';
                fieldelement(a1; "Purchase Invoice Staging"."Entry No.")
                {
                }
                fieldelement(q; "Purchase Invoice Staging"."Date Received")
                {
                }
                fieldelement(w; "Purchase Invoice Staging"."Seller Id")
                {
                }
                fieldelement(e; "Purchase Invoice Staging".Supplier)
                {
                }
                fieldelement(r; "Purchase Invoice Staging".Contract)
                {
                }
                fieldelement(t; "Purchase Invoice Staging"."Item No.")
                {
                }
                fieldelement(y; "Purchase Invoice Staging".Description)
                {
                }
                fieldelement(u; "Purchase Invoice Staging".Quantity)
                {
                }
                fieldelement(i; "Purchase Invoice Staging".Cost)
                {
                }
                fieldelement(o; "Purchase Invoice Staging"."Unit Cost")
                {
                }
                fieldelement(p; "Purchase Invoice Staging".SubTotal)
                {
                }
                fieldelement(s; "Purchase Invoice Staging"."Integration Currency code")
                {
                }
                fieldelement(d; "Purchase Invoice Staging"."Purchase From")
                {
                }
                fieldelement(f; "Purchase Invoice Staging"."Exchange Rate")
                {
                }
                fieldelement(g; "Purchase Invoice Staging".Destination)
                {
                }
                fieldelement(h; "Purchase Invoice Staging"."Date Imported")
                {
                }
                fieldelement(j; "Purchase Invoice Staging"."Imported By")
                {
                }
                fieldelement(k; "Purchase Invoice Staging".Regenerated)
                {
                }
                fieldelement(l; "Purchase Invoice Staging"."Regenerated from Entry No.")
                {
                }
                fieldelement(z; "Purchase Invoice Staging".Processed)
                {
                }
                fieldelement(x; "Purchase Invoice Staging"."Date Processed")
                {
                }
                fieldelement(c; "Purchase Invoice Staging"."Processed By")
                {
                }
                fieldelement(v; "Purchase Invoice Staging"."Has Error")
                {
                }
                fieldelement(b; "Purchase Invoice Staging"."Error 1")
                {
                }
                fieldelement(n; "Purchase Invoice Staging"."Error 2")
                {
                }
                fieldelement(m; "Purchase Invoice Staging"."Error 3")
                {
                }
                fieldelement(zx; "Purchase Invoice Staging"."Error 4")
                {
                }
                fieldelement(cv; "Purchase Invoice Staging"."Error Message")
                {
                }
                trigger OnBeforeInsertRecord()
                var
                    PurchStaging: Record "Purchase Invoice Staging";
                begin
                    if PurchStaging.get("Purchase Invoice Staging"."Entry No.") then
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

