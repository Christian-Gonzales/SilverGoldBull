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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = all;
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    ApplicationArea = all;
                }
                field("Shipment Increment Id"; Rec."Shipment Increment Id")
                {
                    ApplicationArea = all;
                    Caption = 'Document No.';
                }
                field("Order Increment Id"; Rec."Order Increment Id")
                {
                    ApplicationArea = all;
                    Caption = 'External Document No.';
                }
                //field("External Document No."; "External Document No.")
                //{
                //    ApplicationArea = all;
                //}
                field("Customer Id"; Rec."Customer Id")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = CustomerError;
                    Caption = 'Customer No.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = all;
                }
                field("Metal Type"; Rec."Metal Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Metal Type field.';
                    Visible = False;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = ItemError;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = ItemError;
                }
                field("SKU"; Rec."SKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To SKU field.';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = ItemError;

                }
                field("Gen. Product Posting Group"; Rec."Gen. Product Posting Group")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = ItemError;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = ItemError;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = all;
                }
                field("Integration Currency code"; Rec."Integration Currency code")
                {
                    ApplicationArea = all;
                    Style = Attention;
                    StyleExpr = TemplateError;
                }
                field("Shipped From"; Rec."Shipped From")
                {
                    ApplicationArea = all;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = all;
                }
                field("Exchange Rate"; Rec."Exchange Rate")
                {
                    ApplicationArea = all;
                }
                //>>PTC001
                field("PNR No."; rec."PNR No.")
                {
                    ApplicationArea = all;
                }
                field("Booking Ref. No"; rec."Booking Ref. No")
                {
                    ApplicationArea = all;
                }
                field("Passenger Name"; rec."Passenger Name")
                {
                    ApplicationArea = all;
                }

                field("WHT Bus. Posting Group"; rec."WHT Bus. Posting Group")
                {
                    ApplicationArea = all;
                }
                field("WHT Product Posting Group"; rec."WHT Product Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Client Type Code(Dimension)"; rec."Client Type Code(Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Cost Category (Dimension)"; rec."Cost Category (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Cost Center (Dimension)"; rec."Cost Center (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Office Location (Dimension)"; rec."Office Location (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Principal (Dimension)"; rec."Principal (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Product Type (Dimension)"; rec."Product Type (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Product Center (Dimension)"; rec."Profit Center (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("SF Code (Dimension)"; rec."SF Code (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Transact Type (Dimension)"; rec."Transact Type (Dimension)")
                {
                    ApplicationArea = all;
                }
                field("Vessel (Dimension)"; rec."Vessel (Dimension)")
                {
                    ApplicationArea = all;
                }
                //<<PTC001
                field("Date Imported"; Rec."Date Imported")
                {
                    ApplicationArea = all;
                }
                field("Imported By"; Rec."Imported By")
                {
                    ApplicationArea = all;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = all;
                }
                field("Date Processed"; Rec."Date Processed")
                {
                    ApplicationArea = all;
                }
                field("Processed By"; Rec."Processed By")
                {
                    ApplicationArea = all;
                }
                field(Regenerated; Rec.Regenerated)
                {
                    ApplicationArea = all;
                }
                field("Regenerated from Entry No."; Rec."Regenerated from Entry No.")
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
                Visible = false;//PTC001 

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

        Rec.FILTERGROUP(2);
        Rec.SETRANGE(Processed, TRUE);
        Rec.SETRANGE("Shipped From", CompanyInfo."Shipped From");
        Rec.FILTERGROUP(0);
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

