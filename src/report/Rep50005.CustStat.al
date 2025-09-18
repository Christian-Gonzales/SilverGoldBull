report 50005 "Cust Stat"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep50005.CustStat.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            column(Cust_name; Cust_name)
            {
            }
            column(Item_No; Item_No)
            {
            }
            column(TotalQty; TotalQty)
            {
            }
            column(TotalAmount; TotalAmount)
            {
            }
            column(PurchCount; purchcount)
            {
            }

            trigger OnAfterGetRecord()
            begin
                IF CustStat.READ THEN BEGIN
                    Cust_name := CustStat.Sell_to_Customer_No;
                    Item_No := CustStat.ItemNo;
                    TotalQty := CustStat.Sum_Quantity;
                    TotalAmount := CustStat.Sum_Line_Amount;
                    purchcount := CustStat.Count_;
                END
            end;

            trigger OnPostDataItem()
            begin
                CustStat.CLOSE;
            end;

            trigger OnPreDataItem()
            begin
                SETRANGE(Number, 1, 1500);
                CustStat.TOPNUMBEROFROWS;
                CustStat.OPEN;
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

    var
        CustStat: Query "Cust Stat";
        Cust_name: Code[30];
        Item_No: Code[30];
        TotalQty: Decimal;
        TotalAmount: Decimal;
        purchcount: Integer;
}

