report 50002 "CashReceiptPage"
{
    Caption = 'Customer Cash Receipt Staging';
    ProcessingOnly = true;
    UseRequestPage = false;
    //UsageCategory = Lists;
    //ApplicationArea = all;

    dataset
    {
        dataitem(Integer; Integer)
        {
            trigger OnPreDataItem()
            begin
                SetRange(Number, 7, 7);
            end;

            trigger OnAfterGetRecord()
            var
                CompInfo: Record "Company Information";
            begin
                CompInfo.get;
                //if CompInfo."Use New Format" then
                //    page.Run(page::"Cust Cash Rcpt Staging v2")
                //else
                //    page.Run(page::"Customer Cash Receipt Staging");
            end;

            trigger OnPostDataItem()
            begin
                exit;
            end;
        }
    }
}
