page 50000 "Customer and Invoice Staging"
{
    PageType = List;
    SourceTable = "Customer and Invoice Staging";
    Caption = 'Sales Invoice Staging';
    UsageCategory = Lists;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Has Error"; Rec."Has Error")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = HasError;
                }
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
                field("Type"; Rec."Type")
                {
                    ApplicationArea = all;
                    Caption = 'Type';
                    Style = Attention;
                    StyleExpr = ItemError;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = all;
                    Caption = 'No.';
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
                    Visible = False;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = all;
                    Visible = False;
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
                field("Error Message"; Rec."Error Message")
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
                Caption = 'Import Sales Invoice';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IsHandled: Boolean;
                begin
                    OnImportCustomerAndInvoice(IsHandled);

                    if not IsHandled then
                        XMLPORT.RUN(XMLPORT::"Import Customer and Invoice", FALSE, TRUE);

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Check Customer and Invoice")
            {
                ApplicationArea = all;
                Caption = 'Check Staging Data';
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management";
                begin
                    IntegrationMgmt.CheckSales;

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Create Customer and Invoice")
            {
                ApplicationArea = all;
                Caption = 'Create Invoice';
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "SGB Integration Management";
                begin
                    IntegrationMgmt.SalesProcess;
                    Message('Sales Invoice creation completed.');
                    CurrPage.UPDATE(FALSE);
                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        IF Rec."Error Message" <> '' THEN
            HasError := TRUE
        ELSE
            HasError := FALSE;

        IF Rec."Error 1" THEN
            CustomerError := TRUE
        ELSE
            CustomerError := FALSE;

        IF Rec."Error 2" THEN
            ItemError := TRUE
        ELSE
            ItemError := FALSE;

        IF Rec."Error 3" THEN
            TemplateError := TRUE
        ELSE
            TemplateError := FALSE;

        IF Rec."Error 4" THEN
            InvoiceNoError := TRUE
        ELSE
            InvoiceNoError := FALSE;
    end;

    trigger OnOpenPage()
    begin
        CompanyInfo.GET;

        Rec.FILTERGROUP(2);
        Rec.SETRANGE(Processed, FALSE);
        //Rec.SETRANGE("Shipped From", CompanyInfo."Shipped From");
        Rec.FILTERGROUP(0);
    end;

    var
        CompanyInfo: Record "Company Information";
        HasError: Boolean;
        CustomerError: Boolean;
        ItemError: Boolean;
        TemplateError: Boolean;
        InvoiceNoError: Boolean;


    [IntegrationEvent(false, false)]
    local procedure OnImportCustomerAndInvoice(var IsHandled: Boolean)
    begin
    end;
}

