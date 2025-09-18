pageextension 50021 "DirectDebitMandates" extends "Sepa direct debit mandates"  //1230
{
    layout
    {
        addbefore("Customer No.")
        {
            field(Default; Default)
            {
                ApplicationArea = all;
            }
        }
    }

}