pageextension 50022 "DirectDebitCollectionEntries" extends "Direct Debit Collect. Entries"  //1208
{

    layout
    {
        addafter("Applies-to Entry Document No.")
        {
            field("Applies-to Entry Ext. Doc. No."; "Applies-to Entry Ext. Doc. No.")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {

        modify(ResetTransferDate)
        {
            Visible = false;
        }
        addafter(ResetTransferDate)
        {
            action(ResetTransferDate2)
            {
                ApplicationArea = Suite;
                Caption = 'Reset Transfer Date';
                Image = ChangeDates;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Insert today''s date in the Transfer Date field on overdue entries with the status New.';

                trigger OnAction()
                var
                    ConfirmMgt: Codeunit "Confirm Management";
                begin
                    if ConfirmMgt.GetResponse(ResetTransferDateQst, false) then
                        SetTodayAsTransferDateForOverdueEnries2();
                end;
            }
        }
    }
    var
        [InDataSet]
        HasLineErrors: Boolean;
        LineIsEditable: Boolean;
        ResetTransferDateQst: Label 'Do you want to insert today''s date in the Transfer Date field on all overdue entries?';

}