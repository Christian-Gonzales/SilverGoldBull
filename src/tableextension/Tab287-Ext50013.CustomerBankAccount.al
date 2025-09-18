tableextension 50013 "CustomerBankAccount" extends "Customer Bank Account"  //287
{
    fields
    {
        field(50000; "Orig. DFI ID No. Qualifier"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Originating DFI ID Number Qualifier';

        }
        field(50001; "Routing No."; Code[35])
        {
            DataClassification = ToBeClassified;
        }

    }
}