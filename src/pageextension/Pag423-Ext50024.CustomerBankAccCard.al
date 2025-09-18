pageextension 50024 "CustomerBankAccCard" extends "Customer Bank Account Card"  //423
{
    layout
    {
        addafter(IBAN)
        {
            field("Orig. DFI ID No. Qualifier"; "Orig. DFI ID No. Qualifier")
            {
                ApplicationArea = all;
            }
            field("Routing No."; "Routing No.")
            {
                ApplicationArea = all;
            }
        }
    }

}