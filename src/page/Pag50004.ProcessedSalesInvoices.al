page 50004 "Processed Sales Invoices"
{
    // SBg002  YD  20151120  Add button "Regenerate Customer and Invoice Staging"

    Editable = false;
    PageType = List;
    SourceTable = "Customer and Invoice Staging";
    UsageCategory = History;
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
                field(Regenerated; Regenerated)
                {
                    ApplicationArea = all;
                }
                field("Regenerated from Entry No."; "Regenerated from Entry No.")
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
            action("Regenerate Customer and Invoice Staging")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SGBIntegrationManagement: Codeunit "SGB Integration Management";
                    LocalCustomerInvoiceStaging: Record "Customer and Invoice Staging";
                begin
                    CurrPage.SETSELECTIONFILTER(LocalCustomerInvoiceStaging);

                    IF CONFIRM(Text50000, FALSE) THEN
                        SGBIntegrationManagement.ReGenerateCustomerandInvoiceStaging(LocalCustomerInvoiceStaging)
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        CompanyInfo.GET;

        FILTERGROUP(2);
        SETRANGE(Processed, TRUE);
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
        Text50000: Label 'Do you want to regenerate the selected invoice(s)?';
}

