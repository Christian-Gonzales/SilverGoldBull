page 50007 "Processed Purchase Invoices"
{
    // SBg002  YD  20151120  Add button "Regenerate Purchase Invoice Staging"

    Caption = 'Processed Purchase Invoice Staging Old';
    Editable = false;
    PageType = List;
    SourceTable = "Purchase Invoice Staging";
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
                field("Unit Cost"; "Unit Cost")
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

            action("Regenerate Purchase Invoice Staging")
            {
                ApplicationArea = all;
                Caption = 'Regenerate Purchase Invoice Staging';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SGBIntegrationManagement: Codeunit "SGB Integration Management Old";
                    LocalPurchInvoiceStaging: Record "Purchase Invoice Staging";
                begin
                    CurrPage.SETSELECTIONFILTER(LocalPurchInvoiceStaging);
                    IF CONFIRM(Text50000, FALSE) THEN
                        SGBIntegrationManagement.ReGeneratePurchInvoiceStaging(LocalPurchInvoiceStaging)
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        CompanyInfo.GET;

        FILTERGROUP(2);
        SETRANGE(Processed, TRUE);
        SETRANGE("Purchase From", CompanyInfo."Shipped From");
        FILTERGROUP(0);
    end;

    var
        CompanyInfo: Record "Company Information";
        Text50000: Label 'Do you want to regenerate the selected invoice(s)?';
}

