report 50003 "BALEntry"
{
    Caption = 'BALEntry';
    RDLCLayout = './src/report/Rep50003.BALEntry.rdlc';
    Permissions = TableData "Bank Account Ledger Entry" = rimd;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(BankAccountLedgerEntry; "Bank Account Ledger Entry")
        {
            column(EntryNo; "Entry No.")
            {
            }
            trigger OnAfterGetRecord()
            var
            begin
                if STRPOS(UPPERCASE(UserId), 'SYSTEMA') = 0 then
                    error('For admin only');
                if BankAccountLedgerEntry.GetFilter("Entry No.") = '' then
                    error('Entry No. filter must have value.');

                "Statement Status" := "Statement Status"::Open;
                "Statement No." := '';
                "Statement Line No." := 0;
                Modify();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
        trigger OnOpenPage()
        var
        begin
            if STRPOS(UPPERCASE(UserId), 'SYSTEMA') = 0 then
                error('For admin only.');
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean;
        var
        begin
            case UPPERCASE(FORMAT(CloseAction)) of
                'OK':
                    begin
                        if BankAccountLedgerEntry.GetFilter("Entry No.") = '' then
                            error('Entry No. filter must have value.');

                        if Confirm('Are you sure?') then
                            exit(true);
                    end;

                'CANCEL':
                    exit(true);
                else
                    exit(false)
            end;
        end;
    }
}
