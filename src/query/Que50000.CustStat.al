query 50000 "Cust Stat"
{
    OrderBy = Descending(Count_);
    TopNumberOfRows = 5000;

    elements
    {
        dataitem(Sales_Invoice_Line; "Sales Invoice Line")
        {
            filter(Posting_Date; "Posting Date")
            {
            }
            column(Sell_to_Customer_No; "Sell-to Customer No.")
            {
            }
            column(Type; Type)
            {
                ColumnFilter = Type = CONST(Item);
            }
            column(ItemNo; "No.")
            {
                ColumnFilter = ItemNo = FILTER(<> 'Z*'), ItemNo = FILTER(<> ''), ItemNo = FILTER(<> 'BASE METAL SALES');
            }
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
            column(Sum_Line_Amount; "Line Amount")
            {
                Method = Sum;
            }
            column(Count_)
            {
                ColumnFilter = Count_ = FILTER(> 2);
                Method = Count;
            }
        }
    }
}

