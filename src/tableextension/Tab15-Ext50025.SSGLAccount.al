tableextension 50025 "SS G/L Account" extends "G/L Account"  //15
{
    fields
    {
        field(50000; Status; Enum "SS Custom Approval Enum")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    trigger OnAfterInsert()
    begin
        GLSetup.Get();
        if GLSetup."G/L Account Workflow" then begin
            Blocked := true;
            Modify();
        end;

    end;

    var
        GLSetup: Record "General Ledger Setup";
}
