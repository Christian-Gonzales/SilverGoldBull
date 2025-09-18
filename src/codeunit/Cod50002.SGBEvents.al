codeunit 50002 "SGB Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeItemJnlPostLine', '', true, true)]
    local procedure PurchPost_OnBeforeItemJnlPostLine(var ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; var IsHandled: Boolean; WhseReceiptHeader: Record "Warehouse Receipt Header"; WhseShipmentHeader: Record "Warehouse Shipment Header"; TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; TempWarehouseReceiptHeader: Record "Warehouse Receipt Header" temporary; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.")
    begin
        ItemJournalLine.SKU := PurchaseLine.SKU;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeItemJnlPostLine', '', true, true)]
    local procedure OnBeforeItemJnlPostLine(var ItemJournalLine: Record "Item Journal Line"; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary)
    begin
        ItemJournalLine.SKU := SalesLine.SKU;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', true, true)]
    local procedure ItemJnlPostLine_OnBeforeInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean; OldItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLineOrigin: Record "Item Journal Line")
    begin
        ItemLedgerEntry.SKU := ItemJournalLine.SKU;
    end;

    [EventSubscriber(ObjectType::Table, 1208, 'OnBeforeCheckSEPA', '', true, true)]
    local procedure CheckDDLIne(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var IsHandled: Boolean)
    begin
        Codeunit.Run(Codeunit::"SEPA DD-Check Line All Curr.", DirectDebitCollectionEntry);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, 1208, 'OnBeforeExportSEPA', '', true, true)]
    local procedure ExportDDLIne(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var IsHandled: Boolean)
    begin
        //Insert export codeunit here SEPA DD-Export File
        CODEUNIT.RUN(CODEUNIT::"Export Direct Debit", DirectDebitCollectionEntry);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', true, true)]
    local procedure AssignDefaultDirectDebitMandate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        DDMandate: Record "SEPA Direct Debit Mandate";
    begin
        DDMandate.SetRange("Customer No.", Rec."Bill-to Customer No.");
        DDMandate.SetRange(Default, true);
        if DDMandate.FindFirst() then begin
            if DDMandate.Blocked then
                error('Default Direct Debit Mandate assigned to customer %1 is blocked.', Rec."Bill-to Customer No.");
            if DDMandate.Closed then
                error('Default Direct Debit Mandate assigned to customer %1 is closed.', Rec."Bill-to Customer No.");
            if (DDMandate."Valid From" <> 0D) and (DDMandate."Valid To" <> 0D) then
                if (rec."Due Date" < DDMandate."Valid From") and (rec."Due Date" > DDMandate."Valid To") then
                    error('Default Direct Debit Mandate assigned to customer %1 does not have a valid date for Due Date %2', Rec."Bill-to Customer No.", Rec."Due Date");
            rec.validate("Direct Debit Mandate ID", DDMandate.ID);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    //var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean)
    //(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var SalesInvLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var xSalesLine: Record "Sales Line")
    local procedure PostPositiveAdjustmentLTH(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean)
    var
        ItemJnlPostLn: Codeunit "Item Jnl.-Post Line";
        ItemJnlLn: Record "Item Journal Line";
        IntegrationSetup: Record "Integration Setup";
        Item: Record Item;
        LastLineNo: Integer;
        SalesShptLine: Record "Sales Shipment Line";
    begin
        //Getlast Line No. 
        ItemJnlLn.Reset();
        ItemJnlLn.SetRange("Journal Template Name", 'ITEM');
        ItemJnlLn.SetRange("Journal Batch Name", 'SO_INTEG');
        if ItemJnlLn.FindLast() then
            LastLineNo := ItemJnlLn."Line No."
        else
            LastLineNo := 0;

        //Applicable Only for items with LTH=true and LTHSHIP = false
        SalesShptLine.SetRange("Document No.", SalesShptHdrNo);
        SalesShptLine.SetRange(LTH, true);
        SalesShptLine.SetRange(LTHSHIP, false);
        SalesShptLine.SetFilter(Quantity, '<>%1', 0);
        if SalesShptLine.FindSet() then
            repeat
                Item.Get(SalesShptLine."No.");
                if (Item.Type = Item.Type::Inventory) then begin
                    ItemJnlLn.Init();
                    ItemJnlLn."Journal Template Name" := 'ITEM';
                    ItemJnlLn."Journal Batch Name" := 'SO_INTEG';

                    LastLineNo := LastLineNo + 10000;
                    ItemJnlLn."Line No." := LastLineNo;

                    ItemJnlLn."Document No." := SalesHeader."No.";
                    ItemJnlLn.Validate("Entry Type", ItemJnlLn."Entry Type"::"Positive Adjmt.");
                    ItemJnlLn.Validate("Posting Date", SalesHeader."Posting Date");
                    ItemJnlLn.Validate("Item No.", SalesShptLine."No.");
                    ItemJnlLn.Validate(Quantity, SalesShptLine.Quantity);
                    ItemJnlLn.Validate("Unit Amount", SalesShptLine."Unit Price");
                    ItemJnlLn.Validate("Unit Cost", SalesShptLine."Unit Cost");
                    ItemJnlLn.Validate("External Document No.", SalesHeader."External Document No.");
                    ItemJnlLn.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
                    ItemJnlLn.Validate("Applies-to Entry", 0);

                    IntegrationSetup.Get();
                    ItemJnlLn.Validate("Gen. Prod. Posting Group", IntegrationSetup."Sales Gen. Prod Posting Group");
                    ItemJnlLn.Validate("Gen. Bus. Posting Group", '');

                    ItemJnlLn.Insert();
                    Clear(ItemJnlPostLn);
                    ItemJnlPostLn.Run(ItemJnlLn);
                end;
            until SalesShptLine.next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header";
    var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    SalesShptHdrNo: Code[20];
    RetRcpHdrNo: Code[20];
    SalesInvHdrNo: Code[20];
    SalesCrMemoHdrNo: Code[20];
    CommitIsSuppressed: Boolean;
    InvtPickPutaway: Boolean;
    var CustLedgerEntry: Record "Cust. Ledger Entry";
    WhseShip: Boolean;
    WhseReceiv: Boolean);
    var
        L_SIH: Record "Sales Invoice Header";
        L_CLE: Record "Cust. Ledger Entry";
        L_SalesSetup: Record "Sales & Receivables Setup";
        CUMultiplePayment: Codeunit "Multiple Payment Application";
    begin
        L_SalesSetup.Get;
        IF not L_SalesSetup."SO/SI Auto Posting" then exit;
        IF not ((SalesHeader."Document Type" = SalesHeader."Document Type"::Order) OR (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice)) then exit;

        CUMultiplePayment.SOSIAutoApplyPostPayment(SalesHeader, CustLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeCheckExternalDocumentNumber', '', false, false)]
    local procedure PurchPostOnBeforeCheckExternalDocumentNumber(VendorLedgerEntry: Record "Vendor Ledger Entry"; PurchaseHeader: Record "Purchase Header"; var Handled: Boolean; DocType: Option; ExtDocNo: Text[35])
    var
    begin
        if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice) and (PurchaseHeader."Created from Integration") then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure GenJournalLineOnAfterCopyGenJnlLineFromPurchHeader(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    var
    begin
        if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice) and (PurchaseHeader."Created from Integration") then
            GenJournalLine."Created from Integration" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckPurchExtDocNoProcedure', '', false, false)]
    local procedure GenJnlPostLineOnBeforeCheckPurchExtDocNoProcedure(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
    begin
        if GenJnlLine."System-Created Entry" and GenJnlLine."Created from Integration" then
            IsHandled := true;
    end;

    /*
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"Extension Triggers", 'OnInstallAppPerCompany', '', false, false)]
        local procedure OnInstallAppPerCompany_SetDefaultSetup();
        var
            SalesSetup: Record "Sales & Receivables Setup";
        begin
            if SalesSetup.get then begin
                SalesSetup."SO/SI Auto Posting" := false;
                SalesSetup."Tolerance Amount" := 5;
                SalesSetup."Tolerance Day" := 10;
                SalesSetup.Modify();
            end;
        end;
        */
}