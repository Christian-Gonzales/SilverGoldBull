tableextension 50007 "PurchaseHeader" extends "Purchase Header"  //38
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

    }

    var
        myInt: Integer;
}