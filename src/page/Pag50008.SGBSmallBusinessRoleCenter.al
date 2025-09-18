page 50008 "SGB Small Business Role Center"
{
    Caption = 'Small Business Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control12)
            {
                ShowCaption = false;
                part(Control16; "O365 Activities")
                {
                    AccessByPermission = TableData "G/L Entry" = R;
                    ApplicationArea = all;
                }
                part("Favorite Customers"; 9150) //1374 My Mini Customers
                {
                    Caption = 'Favorite Customers';
                    ApplicationArea = all;
                }
            }
            group(Control10)
            {
                ShowCaption = false;
                part(Control55; "Help And Chart Wrapper")
                {
                    AccessByPermission = TableData "Acc. Schedule Name" = R;
                    ApplicationArea = all;
                }
                part(Control9; "Trial Balance")
                {
                    AccessByPermission = TableData "G/L Entry" = R;
                    ApplicationArea = all;
                }
                part(Control96; "Report Inbox Part")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(New)
            {
                Caption = 'New';
                action("Sales Quote")
                {
                    Caption = 'Sales Quote';
                    Image = Quote;
                    RunObject = Page "Sales Quote"; //1324
                    RunPageMode = Create;
                    ToolTip = 'Create a new sales quote';
                    ApplicationArea = all;
                }
                action("Sales Invoice")
                {
                    Caption = 'Sales Invoice';
                    Image = NewInvoice;
                    RunObject = Page "Sales Invoice"; //1304
                    RunPageMode = Create;
                    ToolTip = 'Create a new sales invoice.';
                    ApplicationArea = all;
                }
                action("Purchase Invoice")
                {
                    Caption = 'Purchase Invoice';
                    Image = NewInvoice;
                    RunObject = Page "Purchase Invoice"; //1354
                    RunPageMode = Create;
                    ToolTip = 'Create a new purchase invoice.';
                    ApplicationArea = all;
                }
            }
            group(Payments)
            {
                Caption = 'Payments';
                action("Payment Registration")
                {
                    Caption = 'Payment Registration';
                    Image = Payment;
                    RunObject = Page "Payment Registration";
                    ToolTip = 'Process your customer''s payments by matching amounts received on your bank account with the related unpaid sales invoices, and then post and apply the payments to your books.';
                    ApplicationArea = all;
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                group(ActionGroup27)
                {
                    Caption = 'Setup';
                    Image = Setup;
                    action("Company Information")
                    {
                        Caption = 'Company Information';
                        Image = CompanyInformation;
                        RunObject = Page "Company Information"; //1352
                        ToolTip = 'Enter the company name, address, and bank information that will be inserted on your business documents.';
                        ApplicationArea = all;
                    }
                    action("General Ledger Setup")
                    {
                        Caption = 'General Ledger Setup';
                        Image = JournalSetup;
                        RunObject = Page "General Ledger Setup"; //1348
                        ToolTip = 'Define your general accounting policies, such as the allowed posting period and how payments are processed. Set up your default dimensions for financial analysis.';
                        ApplicationArea = all;
                    }
                    action("Sales & Receivables Setup")
                    {
                        Caption = 'Sales & Receivables Setup';
                        Image = ReceivablesPayablesSetup;
                        RunObject = Page "Sales & Receivables Setup"; //1350
                        ToolTip = 'Define your general policies for sales invoicing and returns, such as when to show credit and stockout warnings and how to post sales discounts. Set up your number series for creating customers and different sales documents.';
                        ApplicationArea = all;
                    }
                    action("Purchases & Payables Setup")
                    {
                        Caption = 'Purchases & Payables Setup';
                        Image = Purchase;
                        RunObject = Page "Purchases & Payables Setup"; //1349
                        ToolTip = 'Define your general policies for purchase invoicing and returns, such as whether to require vendor invoice numbers and how to post purchase discounts. Set up your number series for creating vendors and different purchase documents.';
                        ApplicationArea = all;
                    }
                    action("Inventory Setup")
                    {
                        Caption = 'Inventory Setup';
                        Image = InventorySetup;
                        RunObject = Page "Inventory Setup"; //1351
                        ToolTip = 'Define your general inventory policies, such as whether to allow negative inventory and how to post and adjust item costs. Set up your number series for creating new inventory items or services.';
                        ApplicationArea = all;
                    }
                    action("Fixed Assets Setup")
                    {
                        Caption = 'Fixed Assets Setup';
                        Image = FixedAssets;
                        RunObject = Page "Fixed Asset Setup"; //1353
                        ToolTip = 'Define your accounting policies for fixed assets, such as the allowed posting period and whether to allow posting to main assets. Set up your number series for creating new fixed assets.';
                        ApplicationArea = all;
                    }
                    action("Human Resources Setup")
                    {
                        ApplicationArea = all;
                        Caption = 'Human Resources Setup';
                        Image = HRSetup;
                        RunObject = Page "Human Resources Setup";
                        ToolTip = 'Set up number series for creating new employee cards and define if employment time is measured by days or hours.';
                    }
                    action("Jobs Setup")
                    {
                        ApplicationArea = all;
                        Caption = 'Jobs Setup';
                        Image = Job;
                        RunObject = Page "Jobs Setup";
                    }
                }
            }
            group("Getting Started")
            {
                Caption = 'Getting Started';
                action("Show/Hide Getting Started")
                {
                    ApplicationArea = all;
                    Caption = 'Show/Hide Getting Started';
                    Image = Help;
                    RunObject = Codeunit "O365 Getting Started Mgt.";
                }
            }
        }
        area(embedding)
        {
            action(Customers)
            {
                ApplicationArea = all;
                Caption = 'Customers';
                RunObject = Page "Customer List"; //1301
            }
            action(Vendors)
            {
                ApplicationArea = all;
                Caption = 'Vendors';
                RunObject = Page "Vendor List"; //1331
            }
            action(Items)
            {
                ApplicationArea = all;
                Caption = 'Items';
                RunObject = Page "Item List"; //1303
            }
            action("Posted Sales Invoices - Simplified")
            {
                ApplicationArea = all;
                Caption = 'Posted Sales Invoices - Simplified';
                RunObject = Page "Posted Sales Invoices";
            }
            action(PostedPurchaseInvoices)
            {
                ApplicationArea = all;
                Caption = 'Posted Purchase Invoices - Simplified';
                RunObject = Page "Posted Purchase Invoices";
            }
        }
        area(sections)
        {
            group(Bookkeeping)
            {
                Caption = 'Bookkeeping';
                Image = Journals;
                action("General Journals")
                {
                    ApplicationArea = all;
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General), Recurring = CONST(false));
                }
                action("Chart of Accounts")
                {
                    ApplicationArea = all;
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
                }
                action("G/L Budgets")
                {
                    ApplicationArea = all;
                    Caption = 'G/L Budgets';
                    RunObject = Page "G/L Budget Names";
                }
                action("Fixed Assets")
                {
                    ApplicationArea = all;
                    Caption = 'Fixed Assets';
                    RunObject = Page "Fixed Asset List";
                }
                action("Cash Receipt Journals")
                {
                    ApplicationArea = all;
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Cash Receipts"), Recurring = CONST(false));
                }
                action("Payment Journals")
                {
                    ApplicationArea = all;
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Payments), Recurring = CONST(false));
                }
                action("Sales Invoices- Simplified")
                {
                    ApplicationArea = all;
                    Caption = 'Sales Invoices- Simplified';
                    RunObject = Page "Sales Invoice List";
                }
                action(Action56)
                {
                    ApplicationArea = all;
                    Caption = 'Posted Sales Invoices - Simplified';
                    RunObject = Page "Posted Sales Invoices";
                }
                action("Sales Credit Memos - Simplified")
                {
                    ApplicationArea = all;
                    Caption = 'Sales Credit Memos - Simplified';
                    RunObject = Page "Sales Credit Memos"; //1317
                }
                action("Posted Sales Credit Memos - Simplified")
                {
                    ApplicationArea = all;
                    Caption = 'Posted Sales Credit Memos - Simplified';
                    RunObject = Page "Posted Sales Credit Memos"; //1321
                }
                action("<Page Mini Purchase Invoices>")
                {
                    ApplicationArea = all;
                    Caption = 'Purchase Invoices  - Simplified';
                    RunObject = Page "Purchase Invoices"; //1356
                }
                action("<Page Mini Posted Purchase Invoices>")
                {
                    ApplicationArea = all;
                    Caption = 'Posted Purchase Invoices  - Simplified';
                    RunObject = Page "Posted Purchase Invoices"; //1359
                }
                action("<Page Mini Purchase Credit Memos>")
                {
                    ApplicationArea = all;
                    Caption = 'Purchase Credit Memos  - Simplified';
                    RunObject = Page "Purchase Credit Memos"; //1367
                }
                action("<Page Mini Posted Purchase Credit Memos>")
                {
                    ApplicationArea = all;
                    Caption = 'Posted Purchase Credit Memos  - Simplified';
                    RunObject = Page "Posted Purchase Credit Memos"; //1371
                }
            }
            group(Analysis)
            {
                Caption = 'Analysis';
                Image = AnalysisView;
                action("Account Schedules")
                {
                    ApplicationArea = all;
                    Caption = 'Account Schedules';
                    RunObject = Page "Account Schedule Names";
                }
            }
            group("Bank & Payments")
            {
                Caption = 'Bank & Payments';
                Image = Bank;
                action("Bank Accounts")
                {
                    ApplicationArea = all;
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = Page "Bank Account List";
                }
                action("Bank Acc. Reconciliations")
                {
                    ApplicationArea = all;
                    Caption = 'Bank Acc. Reconciliations';
                    Image = BankAccountRec;
                    RunObject = Page "Bank Acc. Reconciliation List";
                }
                action("Bank Acc. Statements")
                {
                    ApplicationArea = all;
                    Caption = 'Bank Acc. Statements';
                    Image = BankAccountStatement;
                    RunObject = Page "Bank Account Statement List";
                }
                action(Action3)
                {
                    ApplicationArea = all;
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("General"), Recurring = CONST(false));
                }
                action(Action36)
                {
                    ApplicationArea = all;
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Payments), Recurring = CONST(false));
                }
                action(Action41)
                {
                    ApplicationArea = all;
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Cash Receipts"), Recurring = CONST(false));
                }
                action(Currencies)
                {
                    ApplicationArea = all;
                    Caption = 'Currencies';
                    Image = Currency;
                    RunObject = Page Currencies;
                }
            }
        }
    }
}

