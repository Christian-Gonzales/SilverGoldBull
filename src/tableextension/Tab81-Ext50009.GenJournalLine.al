tableextension 50009 "GenJournalLine" extends "Gen. Journal Line"  //81
{
    fields
    {
        field(50000; "Created from Integration"; Boolean)
        {
            DataClassification = CustomerContent;
        }

        modify("Account type")
        {
            trigger onbeforevalidate()
            //removed validation of description not allowed
            //2016/02/10 Prevent description from being overwritten when user select different account type
            //SGB099
            Begin
                //VALIDATE(Description,Desc);
                Desc := Description;
            End;

            trigger OnAfterValidate()
            begin
                Validate(Description, Desc);
            end;
        }
    }


    var
        myInt: Integer;
        Desc: Text;
}