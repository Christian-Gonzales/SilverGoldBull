page 50006 "ProcessedCustomer Cash Receipt"
{
    // SBg002  YD  20151120  Add button "Regenerate Cash Receipt Staging"

    Caption = 'Processed Customer Cash Receipt';
    Editable = false;
    PageType = List;
    SourceTable = "Customer Cash Receipt Staging";
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
                field("Customer Id"; "Customer Id")
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
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            action("Regenerate Cash Receipt Staging")
            {
                ApplicationArea = all;
                Caption = 'Regenerate Cash Receipt Staging';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SGBIntegrationManagement: Codeunit "SGB Integration Management";
                    LocalCashReceiptStaging: Record "Customer Cash Receipt Staging";
                begin
                    CurrPage.SETSELECTIONFILTER(LocalCashReceiptStaging);
                    IF CONFIRM(Text50000, FALSE, LocalCashReceiptStaging.COUNT) THEN
                        SGBIntegrationManagement.ReGenerateCashReceiptStaging(LocalCashReceiptStaging);
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
        Text50000: Label 'Do you want to regenerate the %1 line(s) of cash receipt?';
}

