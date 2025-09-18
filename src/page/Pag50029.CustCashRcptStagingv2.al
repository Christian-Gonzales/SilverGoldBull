page 50029 "Cust Cash Rcpt Staging v2"
{
    PageType = List;
    SourceTable = "Cust Cash Rcpt Staging v2";
    Caption = 'Customer Cash Receipt Staging New';
    UsageCategory = Lists;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = all;
                }
                field("Customer Id"; "Customer Id")
                {
                    ApplicationArea = all;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = all;
                }
                field("Order Increment Id"; "Order Increment Id")
                {
                    ApplicationArea = all;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = all;
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = PaymentError;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = all;
                }
                field("Integration Currency Code"; "Integration Currency Code")
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = all;
                }
                field("Shipped From"; "Shipped From")
                {
                    ApplicationArea = all;
                }
                field("Exchange Rate"; "Exchange Rate")
                {
                    ApplicationArea = all;
                }
                field("Date Imported"; "Date Imported")
                {
                    ApplicationArea = all;
                }
                field("Imported By"; "Imported By")
                {
                    ApplicationArea = all;
                }

                field(Processed; Processed)
                {
                    ApplicationArea = all;
                }
                field("Date Processed"; "Date Processed")
                {
                    ApplicationArea = all;
                }
                field("Processed By"; "Processed By")
                {
                    ApplicationArea = all;
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = HasError;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            action("Import Customer Payment")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    XMLPORT.RUN(XMLPORT::"Import Customer Payment v2", FALSE, TRUE);

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Check Customer Payment")
            {
                ApplicationArea = all;
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management";
                begin
                    //IntegrationMgmt.CreateCustomers(1);
                    //IntegrationMgmt.CreateCustomersOrder();
                    IntegrationMgmt.CheckCashReceiptJnlV2;

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Create Customer Payment")
            {
                ApplicationArea = all;
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Create Customer and Payment';

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management";
                begin
                    IntegrationMgmt.CreateCustomers(1);
                    IntegrationMgmt.CreateCustomersOrder;
                    IntegrationMgmt.CheckCashReceiptJnlV2;
                    IntegrationMgmt.CreateCashReceiptJnlV2; //SSLT

                    CurrPage.UPDATE(FALSE);
                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        IF "Error Message" <> '' THEN
            HasError := TRUE
        ELSE
            HasError := FALSE;

        IF "Error 1" THEN
            CustomerError := TRUE
        ELSE
            CustomerError := FALSE;

        //IF "Error 2" THEN
        //  ItemError := TRUE
        //ELSE
        //  ItemError := FALSE;

        IF "Error 3" THEN
            PaymentError := TRUE
        ELSE
            PaymentError := FALSE;

        IF "Error 4" THEN
            InvoiceNoError := TRUE
        ELSE
            InvoiceNoError := FALSE;
    end;

    trigger OnOpenPage()
    begin
        CompanyInfo.GET;

        FILTERGROUP(2);
        SETRANGE(Processed, FALSE);
        SETRANGE("Shipped From", CompanyInfo."Shipped From");
        FILTERGROUP(0);
    end;

    var
        CompanyInfo: Record "Company Information";
        HasError: Boolean;
        CustomerError: Boolean;
        ItemError: Boolean;
        PaymentError: Boolean;
        InvoiceNoError: Boolean;
}

