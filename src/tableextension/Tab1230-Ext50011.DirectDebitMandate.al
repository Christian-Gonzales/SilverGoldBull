tableextension 50011 "DirectDebitMandate" extends "SEPA Direct Debit Mandate"  //1230
{
    fields
    {
        field(50000; Default; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                DDM: Record "SEPA Direct Debit Mandate";
            begin
                if Default then begin
                    clear(DDM);
                    DDM.SetRange("Customer No.", "Customer No.");
                    DDM.Setfilter(ID, '<>%1', ID);
                    if DDM.FindSet() then
                        DDM.ModifyAll(Default, false);
                end;
            end;
        }
    }

    var
        myInt: Integer;
}