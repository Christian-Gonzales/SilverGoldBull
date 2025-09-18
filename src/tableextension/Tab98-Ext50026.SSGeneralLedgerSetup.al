tableextension 50026 "SS General Ledger Setup" extends "General Ledger Setup"  //98
{
    fields
    {
        field(50000; "G/L Account Workflow"; Boolean)
        {
            Caption = 'G/L Account Workflow';
            DataClassification = CustomerContent;
        }
    }
}
