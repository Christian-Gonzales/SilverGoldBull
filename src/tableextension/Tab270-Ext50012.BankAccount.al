tableextension 50012 "BankAccount" extends "Bank Account"  //270
{
    fields
    {
        field(50000; "Last DD File Creation No."; integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Last Direct Debit Creation No.';
        }
        field(50001; "Routing No."; Code[35])
        {
            DataClassification = ToBeClassified;
            Caption = 'Routing No.';
        }
        field(50002; "Direct Debit Header (PROD)"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Direct Debit Header (PROD)';
        }

    }

}