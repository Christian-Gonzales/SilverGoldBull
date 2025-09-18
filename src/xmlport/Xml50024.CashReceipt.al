xmlport 50024 "CashReceipt"
{

    schema
    {
        textelement(root)
        {
            tableelement("Customer Cash Receipt Staging"; "Customer Cash Receipt Staging")
            {
                XmlName = 'CashReceipt';
                fieldelement(q; "Customer Cash Receipt Staging"."Entry No.")
                {
                }
                fieldelement(w; "Customer Cash Receipt Staging"."Customer Id")
                {
                }
                fieldelement(e; "Customer Cash Receipt Staging"."Order Increment Id")
                {
                }
                fieldelement(r; "Customer Cash Receipt Staging"."Document No.")
                {
                }
                fieldelement(t; "Customer Cash Receipt Staging"."Payment Type")
                {
                }
                fieldelement(y; "Customer Cash Receipt Staging".Amount)
                {
                }
                fieldelement(u; "Customer Cash Receipt Staging"."Integration Currency Code")
                {
                }
                fieldelement(i; "Customer Cash Receipt Staging"."Posting Date")
                {
                }
                fieldelement(o; "Customer Cash Receipt Staging"."Shipped From")
                {
                }
                fieldelement(p; "Customer Cash Receipt Staging"."Exchange Rate")
                {
                }
                fieldelement(a; "Customer Cash Receipt Staging"."Date Imported")
                {
                }
                fieldelement(s; "Customer Cash Receipt Staging"."Imported By")
                {
                }
                fieldelement(d; "Customer Cash Receipt Staging".Regenerated)
                {
                }
                fieldelement(f; "Customer Cash Receipt Staging"."Regenerated from Entry No.")
                {
                }
                fieldelement(g; "Customer Cash Receipt Staging".Processed)
                {
                }
                fieldelement(h; "Customer Cash Receipt Staging"."Date Processed")
                {
                }
                fieldelement(j; "Customer Cash Receipt Staging"."Processed By")
                {
                }
                fieldelement(k; "Customer Cash Receipt Staging"."Has Error")
                {
                }
                fieldelement(l; "Customer Cash Receipt Staging"."Error 1")
                {
                }
                fieldelement(z; "Customer Cash Receipt Staging"."Error 2")
                {
                }
                fieldelement(x; "Customer Cash Receipt Staging"."Error 3")
                {
                }
                fieldelement(c; "Customer Cash Receipt Staging"."Error 4")
                {
                }
                fieldelement(v; "Customer Cash Receipt Staging"."Error Message")
                {
                }
                trigger OnBeforeInsertRecord()
                var
                    CashStaging: Record "Customer Cash Receipt Staging";
                begin
                    if CashStaging.get("Customer Cash Receipt Staging"."Entry No.") then
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

