page 50009 "Customer and Inv. Staging Old"
{
    PageType = List;
    SourceTable = "Customer and Invoice Staging";
    Caption = 'Customer and Invoice Staging Old';
    UsageCategory = Lists;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Has Error"; "Has Error")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Sequence; Sequence)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Invoice Date"; "Invoice Date")
                {
                    ApplicationArea = all;
                }
                field("Order Increment Id"; "Order Increment Id")
                {
                    ApplicationArea = all;
                }
                field("Customer Id"; "Customer Id")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = CustomerError;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = all;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = ItemError;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = all;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = all;
                }
                field("Integration Currency code"; "Integration Currency code")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = TemplateError;
                }
                field("Shipped From"; "Shipped From")
                {
                    ApplicationArea = all;
                }
                field("Country Code"; "Country Code")
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
            action("Import Customer and Invoice")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    XMLPORT.RUN(XMLPORT::"Import Customer and Inv. Old", FALSE, TRUE);
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Check Customer and Invoice")
            {
                ApplicationArea = all;
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management Old";
                begin
                    IntegrationMgmt.CheckSales;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Create Customer and Invoice")
            {
                ApplicationArea = all;
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management Old";
                begin
                    IntegrationMgmt.SalesProcess;

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

        IF "Error 2" THEN
            ItemError := TRUE
        ELSE
            ItemError := FALSE;

        IF "Error 3" THEN
            TemplateError := TRUE
        ELSE
            TemplateError := FALSE;

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
        TemplateError: Boolean;
        InvoiceNoError: Boolean;
}