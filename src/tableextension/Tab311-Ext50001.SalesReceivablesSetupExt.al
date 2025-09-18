tableextension 50001 "Sales & Receivables Setup Ext" extends "Sales & Receivables Setup"  //311
{
    fields
    {
        field(50010; "SO/SI Auto Posting"; Boolean)
        {
            Caption = 'SO/SI Auto Posting';
            DataClassification = ToBeClassified;
        }
        field(50011; "SO/SI Tolerance Amount"; Decimal)
        {
            Caption = 'Tolerance Amount';
            DataClassification = ToBeClassified;
        }
        field(50012; "SO/SI Tolerance Day"; Integer)
        {
            Caption = 'Tolerance Days';
            DataClassification = ToBeClassified;
        }

        field(50013; "Apply to Ext. Doc. No."; Boolean)
        {
            Caption = 'Apply to Ext. Doc. No.';
            DataClassification = ToBeClassified;
        }


    }
}
