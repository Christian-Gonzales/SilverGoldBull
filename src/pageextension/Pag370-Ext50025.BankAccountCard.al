pageextension 50025 "BankAccountCard" extends "Bank Account Card"  //370
{
    layout
    {
        //xtn remove Code
        addafter("SEPA Direct Debit Exp. Format")
        {
            field("Direct Debit Header (PROD)"; "Direct Debit Header (PROD)")
            {
                ApplicationArea = all;
            }
            field("Last DD File Creation No."; "Last DD File Creation No.")
            {
                ApplicationArea = all;
            }
        }
    }
}