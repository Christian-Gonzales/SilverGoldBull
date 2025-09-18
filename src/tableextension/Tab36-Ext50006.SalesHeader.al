tableextension 50006 "SalesHeader" extends "Sales Header"  //36
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Created from Integration"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Automatic Posting Failed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50002; LTH; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50003; LTHSHIP; Boolean)
        {
            DataClassification = ToBeClassified;
        }


    }

    var
        myInt: Integer;
}