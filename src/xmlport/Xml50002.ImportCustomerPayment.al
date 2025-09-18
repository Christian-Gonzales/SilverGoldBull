xmlport 50002 "Import Customer Payment"
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
            tableelement("Customer Cash Receipt Staging";"Customer Cash Receipt Staging")
            {
                XmlName = 'Import';
                fieldelement(f1;"Customer Cash Receipt Staging"."Customer Id")
                {
                }
                fieldelement(f2;"Customer Cash Receipt Staging"."Order Increment Id")
                {
                }
                fieldelement(f3;"Customer Cash Receipt Staging"."Document No.")
                {
                }
                fieldelement(f4;"Customer Cash Receipt Staging"."Payment Type")
                {
                }
                fieldelement(f5;"Customer Cash Receipt Staging".Amount)
                {
                }
                fieldelement(f6;"Customer Cash Receipt Staging"."Integration Currency Code")
                {
                }
                fieldelement(f7;"Customer Cash Receipt Staging"."Posting Date")
                {
                }
                fieldelement(f8;"Customer Cash Receipt Staging"."Shipped From")
                {
                }
                fieldelement(f9;"Customer Cash Receipt Staging"."Exchange Rate")
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

