page 50028 "Processed Sales Orders"
{
    Editable = false;
    PageType = List;
    SourceTable = "Customer and Order Staging";
    UsageCategory = History;

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
                field("Order Date"; "Order Date")
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
                field("Quantity Shipped"; "Quantity Shipped")
                {
                    ApplicationArea = all;
                }
                field(LTH; LTH)
                {
                    ApplicationArea = all;
                }
                field(LTHSHIP; LTHSHIP)
                {
                    ApplicationArea = all;
                }
                field("Shipment Id"; "Shipment Id")
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
            action("Regenerate Customer and Order Staging")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SGBIntegrationManagement: Codeunit "SGB Integration Management";
                    LocalCustomerOrderStaging: Record "Customer and Order Staging";
                begin
                    CurrPage.SETSELECTIONFILTER(LocalCustomerOrderStaging);

                    IF CONFIRM(Text50000, FALSE) THEN
                        SGBIntegrationManagement.ReGenerateCustomerandOrderStaging(LocalCustomerOrderStaging)
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
        OrderNoError: Boolean;
        Text50000: Label 'Do you want to regenerate the selected order(s)?';
}

