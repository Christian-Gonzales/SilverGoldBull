report 50010 "50010"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep50010.50010.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = WHERE("Document Type" = CONST(Invoice));
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD("No.");

                trigger OnAfterGetRecord()
                begin
                    DELETE;
                end;

                trigger OnPostDataItem()
                begin
                    "Sales Header".DELETE;
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

    labels
    {
    }
}

