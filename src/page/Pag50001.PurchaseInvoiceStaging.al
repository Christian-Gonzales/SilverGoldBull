page 50001 "Purchase Invoice Staging"
{
    PageType = List;
    Caption = 'Purchase Invoice Staging Old';
    SourceTable = "Purchase Invoice Staging";
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
                field("Date Received"; "Date Received")
                {
                    ApplicationArea = all;
                }
                field("Seller Id"; "Seller Id")
                {
                    ApplicationArea = all;
                    Caption = 'Seller Id (Vendor No.)';
                }
                field(Supplier; Supplier)
                {
                    ApplicationArea = all;
                }

                field(Contract; Contract)
                {
                    ApplicationArea = all;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                }
                field(Cost; Cost)
                {
                    ApplicationArea = all;
                }
                field(SubTotal; SubTotal)
                {
                    ApplicationArea = all;
                }
                field("Integration Currency code"; "Integration Currency code")
                {
                    ApplicationArea = all;
                }
                field("Purchase From"; "Purchase From")
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
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            action("Import Purchase Invoice")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    XMLPORT.RUN(XMLPORT::"Import Purchase Invoice", FALSE, TRUE);

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Check Purchase Invoice")
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
                    IntegrationMgmt.CheckPurchase;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Create Purchase Invoice")
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
                    IntegrationMgmt.PurchaseProcess;
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
        SETRANGE("Purchase From", CompanyInfo."Shipped From");
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

