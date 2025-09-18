tableextension 50003 "Purch. Rcpt. Line Ext" extends "Purch. Rcpt. Line"  //121
{
    fields
    {
        field(50000; "Integration Receiving ID"; Code[20])
        {
            Caption = 'Integration Receiving ID';
            DataClassification = CustomerContent;
        }
    }
}
