pageextension 50001 "Sales & Receivables Setup Ext" extends "Sales & Receivables Setup"  //459
{
    layout
    {
        addafter(General)
        {
            group(AutoPostingToleranceSetup)
            {
                Caption = 'Auto Posting Tolerance Setup';

                field("SO/SI Auto Posting"; Rec."SO/SI Auto Posting")
                {
                    ApplicationArea = all;
                }
                field("Apply to Ext. Doc. No."; Rec."Apply to Ext. Doc. No.")
                {
                    Caption = 'Apply to Ext. Doc. No.';
                    ApplicationArea = all;
                }
                field("SO/SI Tolerance Amount"; Rec."SO/SI Tolerance Amount")
                {
                    Caption = 'Tolerance Amount';
                    ApplicationArea = all;
                }
                field("SO/SI Tolerance Day"; Rec."SO/SI Tolerance Day")
                {
                    Caption = 'Tolerance Days';
                    ApplicationArea = all;
                }
            }
        }
    }

}
