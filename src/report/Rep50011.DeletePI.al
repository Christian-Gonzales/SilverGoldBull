report 50011 "Delete PI"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep50011.DeletePI.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {

            trigger OnAfterGetRecord()
            begin
                DELETE(TRUE)
            end;

            trigger OnPreDataItem()
            begin
                SETRANGE("Document Type", "Document Type"::Invoice);
            end;
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

