xmlport 50004 "Import Customer Payment v2"
{
    Caption = 'Import Customer Payment';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Cust Cash Rcpt Staging v2"; "Cust Cash Rcpt Staging v2")
            {
                XmlName = 'Import';
                fieldelement(f1; "Cust Cash Rcpt Staging v2"."Customer Id")
                {
                }
                fieldelement(customer_name; "Cust Cash Rcpt Staging v2"."Customer Name")
                {
                }
                fieldelement(f2; "Cust Cash Rcpt Staging v2"."Order Increment Id")
                {
                }
                fieldelement(f3; "Cust Cash Rcpt Staging v2"."Document No.")
                {
                }
                fieldelement(f4; "Cust Cash Rcpt Staging v2"."Payment Type")
                {
                }
                fieldelement(f5; "Cust Cash Rcpt Staging v2".Amount)
                {
                }
                fieldelement(f6; "Cust Cash Rcpt Staging v2"."Integration Currency Code")
                {
                }
                fieldelement(f7; "Cust Cash Rcpt Staging v2"."Posting Date")
                {
                }
                fieldelement(f8; "Cust Cash Rcpt Staging v2"."Shipped From")
                {
                }
                fieldelement(f9; "Cust Cash Rcpt Staging v2"."Exchange Rate")
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

