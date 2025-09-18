report 50001 "Change GL Entry Desc"
{
    Permissions = TableData "G/L Entry" = rm;
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = SORTING("Entry No.");

            trigger OnAfterGetRecord()
            begin
                //"G/L Entry".Description := 'Jaroslav Gresula';
                //"G/L Entry".MODIFY;
            end;

            trigger OnPreDataItem()
            begin
                //"G/L Entry".SETRANGE("G/L Account No.", '11500');
                "G/L Entry".SETFILTER(Description, 'Jaroslav*');
                "G/L Entry".MODIFYALL(Description, 'Jaroslav Gresula');
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

