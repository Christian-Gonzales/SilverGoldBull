pageextension 50041 "SS General Ledger Setup" extends "General Ledger Setup"  //118
{
    layout
    {
        addafter(Control1900309501)
        {
            group(Workflow)
            {
                Caption = 'Workflow';

                field("G/L Account Workflow"; Rec."G/L Account Workflow")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
