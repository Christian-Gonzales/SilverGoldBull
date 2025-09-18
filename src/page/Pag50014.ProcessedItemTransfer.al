page 50014 "Processed Item Transfer"
{
    ApplicationArea = All;
    Caption = 'Processed Item Transfer Staging';
    PageType = List;
    SourceTable = "Item Transfer Staging";
    UsageCategory = History;
    Editable = false;

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
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                    Style = Attention;
                    StyleExpr = HasError;
                }
                field("To Base Unit of Measure"; Rec."To Base Unit of Measure")
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
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed field.';
                    Editable = false;
                }
                field("Date Processed"; Rec."Date Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Processed field.';
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

            action("Regenerate Item Transfer Staging")
            {
                ApplicationArea = all;
                Caption = 'Regenerate Item Transfer Staging';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ItemTransferMgmt: Codeunit ItemTransferMgmt;
                    ItemTransferStaging: Record "Item Transfer Staging";
                begin
                    CurrPage.SETSELECTIONFILTER(ItemTransferStaging);
                    IF CONFIRM(Text50000, FALSE) THEN
                        ItemTransferMgmt.RegenerateItemTransferStaging(ItemTransferStaging);
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
        Rec.SetRange(Processed, true);
        Rec.FilterGroup(0);
    end;

    var
        HasError: Boolean;
        Text50000: Label 'Do you want to regenerate the selected item transfer(s)?';
}
