page 50013 "Item Transfer Staging"
{
    ApplicationArea = All;
    Caption = 'Item Transfer Staging';
    PageType = List;
    SourceTable = "Item Transfer Staging";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("From Item No."; Rec."From Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Item No. field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("From Item Description"; Rec."From Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Item Description field.';
                }
                field("To Metal Type"; Rec."To Metal Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Metal Type field.';
                }
                field("To Item No."; Rec."To Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Item No. field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("To Item Description"; Rec."To Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Item Description field.';
                }
                field("SKU"; Rec."SKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To SKU field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("Base Unit of Measure"; Rec."To Base Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Base Unit of Measure field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("To Gen. Prod. Posting Group"; Rec."To Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("To Inventory Posting Group"; Rec."To Inventory Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("Date Imported"; Rec."Date Imported")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Imported field.';
                    Editable = false;
                }
                field("Imported By"; Rec."Imported By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Imported By field.';
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message field.';
                    Style = Attention;
                    StyleExpr = HasError;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            action("Import Item Transfer")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Import Item Transfer action.';
                trigger OnAction()
                var
                    IsHandled: Boolean;
                begin
                    if not IsHandled then
                        XMLPORT.RUN(XMLPORT::"Import Item Transfer Staging", FALSE, TRUE);

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Check Item Transfer")
            {
                ApplicationArea = all;
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Check Item Transfer action.';
                trigger OnAction()
                var
                    ItemTransferMgmt: Codeunit ItemTransferMgmt;
                begin
                    ItemTransferMgmt.Check();

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Create Item Transfer")
            {
                ApplicationArea = all;
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Create Item Transfer action.';
                trigger OnAction()
                var
                    ItemTransferMgmt: Codeunit ItemTransferMgmt;
                begin
                    ItemTransferMgmt.Create();

                    CurrPage.UPDATE(FALSE);
                end;
            }

        }
    }


    trigger OnAfterGetRecord()
    begin
        if Rec."Error Message" <> '' then
            HasError := true
        else
            HasError := false;
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Processed, FALSE);
        Rec.FilterGroup(0);
    end;

    var
        HasError: Boolean;
}
