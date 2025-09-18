report 50000 "SGB Check (Check/Stub/Stub)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep50000.SGBCheckCheckStubStub.rdlc';
    Caption = 'Check (Check/Stub/Stub)';
    Permissions = TableData "Bank Account" = m;

    //xtn Remove Code
}

