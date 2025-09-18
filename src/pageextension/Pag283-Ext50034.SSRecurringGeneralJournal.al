pageextension 50034 "SS Recurring General Journal" extends "Recurring General Journal"  //283
{

    actions
    {
        addlast(processing)
        {
            action(Approvals)
            {
                AccessByPermission = TableData "Approval Entry" = R;
                ApplicationArea = Suite;
                Caption = 'Approvals';
                Image = Approvals;
                ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                trigger OnAction()
                var
                    [SecurityFiltering(SecurityFilter::Filtered)]
                    GenJournalLine: Record "Gen. Journal Line";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    GetCurrentlySelectedLines(GenJournalLine);
                    ApprovalsMgmt.ShowJournalApprovalEntries(GenJournalLine);
                end;
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                group(SendApprovalRequest)
                {
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = not OpenApprovalEntriesOnBatchOrAnyJnlLineExist and CanRequestFlowApprovalForBatchAndAllLines and EnabledGenJnlBatchWorkflowsExist;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                            SetControlAppearanceFromBatch();
                            SetControlAppearance();
                        end;
                    }
                    action(SendApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = not OpenApprovalEntriesOnBatchOrCurrJnlLineExist and CanRequestFlowApprovalForBatchAndCurrentLine and EnabledGenJnlLineWorkflowsExist;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send selected journal lines for approval.';

                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            GenJournalLine: Record "Gen. Journal Line";
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            GetCurrentlySelectedLines(GenJournalLine);
                            ApprovalsMgmt.SendJournalLinesApprovalRequests(GenJournalLine);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                }
                group(CancelApprovalRequest)
                {
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = CanCancelApprovalForJnlBatch or CanCancelFlowApprovalForBatch;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                            SetControlAppearance();
                            SetControlAppearanceFromBatch();
                        end;
                    }
                    action(CancelApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = CanCancelApprovalForJnlLine or CanCancelFlowApprovalForLine;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending selected journal lines for approval.';

                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            GenJournalLine: Record "Gen. Journal Line";
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            GetCurrentlySelectedLines(GenJournalLine);
                            ApprovalsMgmt.TryCancelJournalLineApprovalRequests(GenJournalLine);
                        end;
                    }
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveGenJournalLineRequest(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectGenJournalLineRequest(Rec);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateGenJournalLineRequest(Rec);
                    end;
                }
                action(Comments)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser or ApprovalEntriesExistSentByCurrentUser;

                    trigger OnAction()
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if OpenApprovalEntriesOnJnlLineExist then
                            ApprovalsMgmt.GetApprovalComment(Rec)
                        else
                            if OpenApprovalEntriesOnJnlBatchExist then
                                if GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
                                    ApprovalsMgmt.GetApprovalComment(GenJournalBatch);
                    end;
                }
            }
        }
        addlast(Promoted)
        {
            group("Category_Request Approval")
            {
                Caption = 'Request Approval';

                group("Category_Send Approval Request")
                {
                    Caption = 'Send Approval Request';

                    actionref(SendApprovalRequestJournalBatch_Promoted; SendApprovalRequestJournalBatch)
                    {
                    }
                    actionref(SendApprovalRequestJournalLine_Promoted; SendApprovalRequestJournalLine)
                    {
                    }
                }
                group("Category_Cancel Approval Request")
                {
                    Caption = 'Cancel Approval Request';

                    actionref(CancelApprovalRequestJournalBatch_Promoted; CancelApprovalRequestJournalBatch)
                    {
                    }
                    actionref(CancelApprovalRequestJournalLine_Promoted; CancelApprovalRequestJournalLine)
                    {
                    }
                }
            }
        }
    }



    trigger OnAfterGetCurrRecord()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);

        SetControlAppearance();
        if GenJournalBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJnlBatchName) then
            SetApprovalStateForBatch(GenJournalBatch, Rec, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesOnJnlBatchExist, OpenApprovalEntriesOnBatchOrAnyJnlLineExist, CanCancelApprovalForJnlBatch, CanRequestFlowApprovalForBatch, CanCancelFlowApprovalForBatch, CanRequestFlowApprovalForBatchAndAllLines, ApprovalEntriesExistSentByCurrentUser, EnabledGenJnlBatchWorkflowsExist, EnabledGenJnlLineWorkflowsExist);

        ApprovalMgmt.GetGenJnlBatchApprovalStatus(Rec, GenJnlBatchApprovalStatus, EnabledGenJnlBatchWorkflowsExist);
    end;


    local procedure GetCurrentlySelectedLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        CurrPage.SetSelectionFilter(GenJournalLine);
        exit(GenJournalLine.FindSet());
    end;

    local procedure SetControlAppearance()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if not GenJournalBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJnlBatchName) then
            exit;
        SetApprovalState(Rec.RecordId, OpenApprovalEntriesOnJnlBatchExist, CanRequestFlowApprovalForBatch, CanCancelFlowApprovalForLine, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesOnJnlLineExist, OpenApprovalEntriesOnBatchOrCurrJnlLineExist, CanCancelApprovalForJnlLine, CanRequestFlowApprovalForBatchAndCurrentLine, EnabledGenJnlLineWorkflowsExist, EnabledGenJnlBatchWorkflowsExist, CanCancelApprovalForJnlBatch, GenJournalBatch);
        //ShowWorkflowStatusOnLine := CurrPage.WorkflowStatusLine.PAGE.SetFilterOnWorkflowRecord(Rec.RecordId);
        //SetPayrollAppearance();
    end;

    local procedure SetControlAppearanceFromBatch()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        //if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::ODataV4 then
        //    exit;

        if not GenJournalBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJnlBatchName) then
            exit;

        //ShowWorkflowStatusOnBatch := CurrPage.WorkflowStatusBatch.PAGE.SetFilterOnWorkflowRecord(GenJournalBatch.RecordId);
        SetApprovalStateForBatch(GenJournalBatch, Rec, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesOnJnlBatchExist, OpenApprovalEntriesOnBatchOrAnyJnlLineExist, CanCancelApprovalForJnlBatch, CanRequestFlowApprovalForBatch, CanCancelFlowApprovalForBatch, CanRequestFlowApprovalForBatchAndAllLines, ApprovalEntriesExistSentByCurrentUser, EnabledGenJnlBatchWorkflowsExist, EnabledGenJnlLineWorkflowsExist);
        BackgroundErrorCheck := BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled();
        ShowAllLinesEnabled := true;
        Rec.SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
        JournalErrorsMgt.SetFullBatchCheck(true);
    end;

    internal procedure SetApprovalState(RecordId: RecordId; OpenApprovalEntriesOnJournalBatchExist: Boolean; LocalCanRequestFlowApprovalForBatch: Boolean; var LocalCanCancelFlowApprovalForLine: Boolean; var OpenApprovalEntriesExistForCurrentUser: Boolean; var OpenApprovalEntriesOnJournalLineExist: Boolean; var OpenApprovalEntriesOnBatchOrCurrentJournalLineExist: Boolean; var CanCancelApprovalForJournalLine: Boolean; var LocalCanRequestFlowApprovalForBatchAndCurrentLine: Boolean; var EnabledGeneralJournalLineWorkflowsExist: Boolean; var EnabledGeneralJournalBatchWorkflowsExist: Boolean; var CanCancelApprovalForJournalBatch: Boolean; GenJournalBatch: Record "Gen. Journal Batch")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        CanRequestFlowApprovalForLine: Boolean;
    begin
        OpenApprovalEntriesExistForCurrentUser := OpenApprovalEntriesExistForCurrentUser or ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        OpenApprovalEntriesOnJournalLineExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
        OpenApprovalEntriesOnBatchOrCurrentJournalLineExist := OpenApprovalEntriesOnJournalBatchExist or OpenApprovalEntriesOnJournalLineExist;
        CanCancelApprovalForJournalLine := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);
        CanCancelApprovalForJournalBatch := ApprovalsMgmt.CanCancelApprovalForRecord(GenJournalBatch.RecordId);
        WorkflowWebhookManagement.GetCanRequestAndCanCancel(RecordId, CanRequestFlowApprovalForLine, LocalCanCancelFlowApprovalForLine);
        LocalCanRequestFlowApprovalForBatchAndCurrentLine := CanRequestFlowApprovalForLine;
        //LocalCanRequestFlowApprovalForBatch and

        EnabledGeneralJournalLineWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Gen. Journal Line", WorkflowEventHandling.RunWorkflowOnSendGeneralJournalLineForApprovalCode());
        EnabledGeneralJournalBatchWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Gen. Journal Batch", WorkflowEventHandling.RunWorkflowOnSendGeneralJournalBatchForApprovalCode());
    end;


    internal procedure SetApprovalStateForBatch(GenJournalBatch: Record "Gen. Journal Batch"; GenJournalLine: Record "Gen. Journal Line"; var OpenApprovalEntriesExistForCurrentUser: Boolean; var OpenApprovalEntriesOnJournalBatchExist: Boolean; var OpenApprovalEntriesOnBatchOrAnyJournalLineExist: Boolean; var CanCancelApprovalForJournalBatch: Boolean; var LocalCanRequestFlowApprovalForBatch: Boolean; var LocalCanCancelFlowApprovalForBatch: Boolean; var LocalCanRequestFlowApprovalForBatchAndAllLines: Boolean; var LocalApprovalEntriesExistSentByCurrentUser: Boolean; var EnabledGeneralJournalBatchWorkflowsExist: Boolean; var EnabledGeneralJournalLineWorkflowsExist: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        CanRequestFlowApprovalForAllLines: Boolean;
    begin
        OpenApprovalEntriesExistForCurrentUser := OpenApprovalEntriesExistForCurrentUser or ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(GenJournalBatch.RecordId);
        OpenApprovalEntriesOnJournalBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(GenJournalBatch.RecordId);
        OpenApprovalEntriesOnBatchOrAnyJournalLineExist := OpenApprovalEntriesOnJournalBatchExist or ApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        CanCancelApprovalForJournalBatch := ApprovalsMgmt.CanCancelApprovalForRecord(GenJournalBatch.RecordId);
        WorkflowWebhookManagement.GetCanRequestAndCanCancelJournalBatch(GenJournalBatch, LocalCanRequestFlowApprovalForBatch, LocalCanCancelFlowApprovalForBatch, CanRequestFlowApprovalForAllLines);
        LocalCanRequestFlowApprovalForBatchAndAllLines := LocalCanRequestFlowApprovalForBatch;
        // and CanRequestFlowApprovalForAllLines
        LocalApprovalEntriesExistSentByCurrentUser := ApprovalsMgmt.HasApprovalEntriesSentByCurrentUser(GenJournalBatch.RecordId) or ApprovalsMgmt.HasApprovalEntriesSentByCurrentUser(GenJournalLine.RecordId);

        EnabledGeneralJournalLineWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Gen. Journal Line", WorkflowEventHandling.RunWorkflowOnSendGeneralJournalLineForApprovalCode());
        EnabledGeneralJournalBatchWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Gen. Journal Batch", WorkflowEventHandling.RunWorkflowOnSendGeneralJournalBatchForApprovalCode());
    end;

    local procedure GetJournalTemplateNameFromFilter(): Text[10]
    begin
        if Rec.GetFilter("Journal Template Name") = '' then
            exit;

        exit(Rec.GetRangeMax("Journal Template Name"));
    end;


    var
        ApprovalEntriesExistSentByCurrentUser: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesOnJnlBatchExist: Boolean;
        OpenApprovalEntriesOnJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrAnyJnlLineExist: Boolean;
        CanCancelApprovalForJnlLine: Boolean;
        EnabledGenJnlBatchWorkflowsExist: Boolean;
        CanCancelFlowApprovalForLine: Boolean;
        CanCancelApprovalForJnlBatch: Boolean;
        CanCancelFlowApprovalForBatch: Boolean;
        EnabledGenJnlLineWorkflowsExist: Boolean;
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist: Boolean;
        CanRequestFlowApprovalForBatch: Boolean;
        CanRequestFlowApprovalForBatchAndAllLines: Boolean;
        CanRequestFlowApprovalForBatchAndCurrentLine: Boolean;

        ShowWorkflowStatusOnLine: Boolean;

        ShowWorkflowStatusOnBatch: Boolean;

        BackgroundErrorCheck: Boolean;

        ShowAllLinesEnabled: Boolean;

        JournalErrorsMgt: Codeunit "Journal Errors Mgt.";

        BackgroundErrorHandlingMgt: Codeunit "Background Error Handling Mgt.";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";

        GenJnlBatchApprovalStatus: Text[20];
}
