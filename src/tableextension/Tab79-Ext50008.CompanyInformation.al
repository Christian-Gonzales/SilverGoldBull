tableextension 50008 "CompanyInformation" extends "Company Information"  //79
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Shipped From"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(50001; "Use Exchange Rate"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Active Shipped From"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}