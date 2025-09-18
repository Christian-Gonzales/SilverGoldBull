page 50020 "Import Export Data"
{
    UsageCategory = Tasks;
    //ApplicationArea = all;

    layout
    {



    }

    actions
    {
        area(creation)
        {
            action("Import Customer Staging")
            {
                RunObject = XMLport CustStaging;
                ApplicationArea = all;
                Caption = 'Import Customer and Invoice Staging';
            }
            action("Import Purchase Invoice Staging")
            {
                RunObject = XMLport "Purch Staging";
                ApplicationArea = all;
                Caption = 'Import Purchase Invoice Staging';
            }
            action("Import Cash Receipt")
            {
                RunObject = XMLport CashReceipt;
                ApplicationArea = all;
                Caption = 'Import Cash Receipt Staging';
            }
            action("Import Payment Type")
            {
                RunObject = XMLport PaymntType;
                ApplicationArea = all;
                Caption = 'Import Payment Type Mapping';
            }
        }
    }
}

