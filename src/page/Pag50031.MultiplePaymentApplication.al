page 50031 "Multiple Payment Application"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Multiple Payment Application';
    DataCaptionFields = "Customer No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    Permissions = TableData "Cust. Ledger Entry" = m;
    PromotedActionCategories = 'New,Process,Report,Line,Entry,Navigate';
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending) where("Document Type" = const(Payment), Open = const(true), "External Document No." = filter(<> ''));
    UsageCategory = Tasks;

    //xtn Remove Code

}


