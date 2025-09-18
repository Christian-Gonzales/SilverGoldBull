page 50010 "Purchase Invoice Staging New"
{
    PageType = List;
    Caption = 'Purchase Invoice Staging New';
    SourceTable = "Purchase Invoice Staging";
    UsageCategory = Lists;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Receiving Date"; Rec."Receiving Date")
                {
                    ApplicationArea = All;
                    Caption = 'Receipt Date';
                }
                field("Date Received"; Rec."Date Received")
                {
                    ApplicationArea = All;
                    Caption = 'Date Paid';
                }
                field("Seller Id"; Rec."Seller Id")
                {
                    ApplicationArea = All;
                    Caption = 'Seller Id (Vendor No.)';
                }
                field(Supplier; Rec.Supplier)
                {
                    ApplicationArea = All;
                }
                field("Receiving Id"; Rec."Receiving Id")
                {
                    ApplicationArea = All;
                    Caption = 'Receipt Increment Id';
                }
                field(Contract; Rec.Contract)
                {
                    ApplicationArea = All;
                }
                field("Metal Type"; Rec."Metal Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Metal Type field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("SKU"; Rec."SKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To SKU field.';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = all;
                }
                field("Gen. Product Posting Group"; Rec."Gen. Product Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = all;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Cost; Rec.Cost)
                {
                    ApplicationArea = All;
                }
                field(SubTotal; Rec.SubTotal)
                {
                    ApplicationArea = All;
                }
                field("Integration Currency code"; Rec."Integration Currency code")
                {
                    ApplicationArea = All;
                }
                field("Purchase From"; Rec."Purchase From")
                {
                    ApplicationArea = All;
                }
                field("Exchange Rate"; Rec."Exchange Rate")
                {
                    ApplicationArea = All;
                }
                field("Date Imported"; Rec."Date Imported")
                {
                    ApplicationArea = All;
                }
                field("Imported By"; Rec."Imported By")
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field("Date Processed"; Rec."Date Processed")
                {
                    ApplicationArea = All;
                }
                field("Processed By"; Rec."Processed By")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
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

            action("Import Purchase Invoice")
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IsHandled: Boolean;
                begin
                    OnImportPurchaseInvoice(IsHandled);

                    if not IsHandled then
                        XMLPORT.RUN(XMLPORT::"Import Purchase Invoice v2", FALSE, TRUE);

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Check Purchase Invoice")
            {
                ApplicationArea = All;
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management";
                begin
                    IntegrationMgmt.CheckPurchase;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Create Purchase Invoice")
            {
                ApplicationArea = All;
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management";
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

    [IntegrationEvent(false, false)]
    local procedure OnImportPurchaseInvoice(var IsHandled: Boolean)
    begin
    end;
}

