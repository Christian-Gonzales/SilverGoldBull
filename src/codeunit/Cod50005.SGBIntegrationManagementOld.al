codeunit 50005 "SGB Integration Management Old"
{
    // SGB001  YD  20150901  Start
    // SGB002  YD  20151120  Add three functions ReGenerateCustomerandInvoiceStaging,ReGeneratePurchInvoiceStaging,ReGenerateCashReceiptStaging
    // SGB003  YD  20160115  Apply Template to new customer only
    // SGB005  YD  20160825  Add new field CustomerInvoiceStaging."Country Code"
    // SGB006  YD  20180927  Get Dwscription from staging PurchLine.Description := VendorInvoiceStaging.Description;


    trigger OnRun()
    begin
    end;

    var
        Text50000: Label 'The invoice %1 was imported with Entry No. %2.';
        Text50001: Label '%1 %2 does not exist.';
        Text50002: Label 'The %1 %2 has no Posting Group.';
        Text50003: Label 'There is no NAV Payment Type for %1.';
        Text50004: Label 'There is no template %1 for customer.';
        Text50005: Label 'Do you want to create general journal lines in %1 batch?';
        Text50006: Label 'Nothing is created.';
        Text50007: Label 'The journal entry %1 was import with Entry No. %2.';
        Text50008: Label 'Do you want to create customer and sales invoice?';
        Text50009: Label 'Currency Code between %1 and %2 are different.';
        Text50010: Label 'There are %1 lines and %2 lines have errors.';
        Text50011: Label 'Do you want to create purchase invoice?';
        GLSetup: Record "General Ledger Setup";
        CurrCode: Code[10];
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        Text50012: Label 'There is no Cust. Ledger Entry for %1';
        Text50013: Label 'Payment Date is earlier then the invoice Date.  ';

    procedure CheckSales()
    begin
        CheckSalesInvoices();
    end;

    procedure SalesProcess()
    begin
        CreateCustomers();
        CheckSalesInvoices();
        CreateSalesInvoices();
    end;

    procedure CheckPurchase()
    begin
        CheckPurchInvoices(TRUE);
    end;

    procedure PurchaseProcess()
    begin
        IF NOT CONFIRM(Text50011, FALSE) THEN BEGIN
            MESSAGE(Text50006);
            EXIT
        END;

        CheckPurchInvoices(FALSE);
        CreatePurchInvoices();
    end;

    procedure CreateCustomers()
    var
        CompanyInfo: Record "Company Information";
        IntegrationSetup: Record "Integration Setup";
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        CustomerID: Code[20];
        RecRef: RecordRef;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        TemplateCode: Code[20];
        CustomeInvoiceStaging: Record "Customer and Invoice Staging";
    begin

        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;

        TempCustomer.RESET;
        TempCustomer.DELETEALL;

        CustomeInvoiceStaging.SETCURRENTKEY("Shipped From", Processed);
        CustomeInvoiceStaging.SETRANGE(Processed, FALSE);
        CustomeInvoiceStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");

        IF CustomeInvoiceStaging.FINDSET THEN
            REPEAT

                CustomerID := CustomeInvoiceStaging."Customer Id";
                TemplateCode := CustomeInvoiceStaging."Integration Currency code";

                IF NOT TempCustomer.GET(CustomerID) THEN BEGIN
                    IF Customer.GET(CustomerID) THEN BEGIN
                        Customer.VALIDATE(Name, CustomeInvoiceStaging."Customer Name");
                        Customer.MODIFY;
                    END ELSE BEGIN
                        Customer.INIT;
                        Customer."No." := CustomerID;
                        Customer.VALIDATE(Name, CustomeInvoiceStaging."Customer Name");
                        Customer.INSERT(TRUE);

                        TempCustomer := Customer;
                        TempCustomer.INSERT;
                        //SGB003
                        RecRef.GETTABLE(Customer);
                        ConfigTemplateHeader.GET(TemplateCode);
                        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                        //SGB003

                    END;
                END ELSE BEGIN
                    Customer.GET(CustomerID)
                END;

            //SGB003
            //RecRef.GETTABLE(Customer);
            //ConfigTemplateHeader.GET(TemplateCode);
            //ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
            //SGB003


            UNTIL CustomeInvoiceStaging.NEXT = 0;


        COMMIT;
    end;

    procedure CreateSalesInvoices()
    var
        CustomerInvoiceStaging: Record "Customer and Invoice Staging";
        TempSalesHeader: Record "Sales Header" temporary;
        TempCustomerInvoiceStaging: Record "Customer and Invoice Staging" temporary;
        IntegrationSetup: Record "Integration Setup";
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        Item: Record Item;
        ConfigTemplateHeader: Record "Config. Template Header";
        CompanyInfo: Record "Company Information";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        SalesPost: Codeunit "Sales-Post";
        CustomerID: Code[20];
        RecRef: RecordRef;
        TemplateCode: Code[20];
        PrevDocNo: Code[20];
        NextLineNo: Integer;
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;

        IF NOT CONFIRM(Text50008, FALSE) THEN BEGIN
            MESSAGE(Text50006);
            EXIT
        END;


        TempSalesHeader.RESET;
        TempSalesHeader.DELETEALL;

        TempCustomerInvoiceStaging.RESET;
        TempCustomerInvoiceStaging.DELETEALL;

        PrevDocNo := '';

        CustomerInvoiceStaging.SETCURRENTKEY("Shipped From", Processed);

        CustomerInvoiceStaging.SETRANGE(Processed, FALSE);
        CustomerInvoiceStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");
        CustomerInvoiceStaging.SETRANGE("Has Error", FALSE);
        IF CustomerInvoiceStaging.FINDSET THEN
            REPEAT
                IF CustomerInvoiceStaging."Order Increment Id" <> PrevDocNo THEN BEGIN
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Invoice;
                    TempSalesHeader."No." := CustomerInvoiceStaging."Order Increment Id";
                    TempSalesHeader."Sell-to Customer No." := CustomerInvoiceStaging."Customer Id";
                    TempSalesHeader."Currency Factor" := CustomerInvoiceStaging."Exchange Rate";
                    TempSalesHeader."Posting Date" := CustomerInvoiceStaging."Invoice Date";
                    //SGB005
                    TempSalesHeader."Shortcut Dimension 1 Code" := CustomerInvoiceStaging."Country Code";
                    //SGB005
                    IF TempSalesHeader.INSERT THEN;
                    PrevDocNo := CustomerInvoiceStaging."Order Increment Id";
                END;
            UNTIL CustomerInvoiceStaging.NEXT = 0;


        TempSalesHeader.RESET;
        IF TempSalesHeader.FINDSET THEN
            REPEAT
                CustomerID := TempSalesHeader."Sell-to Customer No.";

                SalesHeader.INIT;
                SalesHeader.SetHideValidationDialog(true);
                SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
                SalesHeader.VALIDATE("No.", TempSalesHeader."No.");
                SalesHeader.VALIDATE("Sell-to Customer No.", CustomerID);
                SalesHeader.VALIDATE("Posting Date", TempSalesHeader."Posting Date");
                SalesHeader."Currency Factor" := 1 / TempSalesHeader."Currency Factor";
                SalesHeader."Posting No." := SalesHeader."No.";
                SalesHeader."Created from Integration" := TRUE;

                //SGB005
                //SalesHeader.VALIDATE("Shortcut Dimension 1 Code",TempSalesHeader."Shortcut Dimension 1 Code");
                //SGB005

                SalesHeader.INSERT(TRUE);


                //SGB005

                SalesHeader.GET(SalesHeader."Document Type"::Invoice, TempSalesHeader."No.");
                //SalesHeader.INIT;
                SalesHeader.VALIDATE("Shortcut Dimension 1 Code", TempSalesHeader."Shortcut Dimension 1 Code");
                SalesHeader.VALIDATE("Document Date", TempSalesHeader."Posting Date");
                SalesHeader.MODIFY;
                //SGB005

                NextLineNo := 0;
                CustomerInvoiceStaging.SETRANGE("Order Increment Id", TempSalesHeader."No.");
                IF CustomerInvoiceStaging.FINDSET THEN
                    REPEAT
                        SalesLine.INIT;
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        NextLineNo += 10000;
                        SalesLine."Line No." := NextLineNo;

                        SalesLine.INSERT(TRUE);

                        Item.SETRANGE("Integration Item", UPPERCASE(CustomerInvoiceStaging."Item No."));
                        Item.FINDFIRST;

                        SalesLine.VALIDATE(Type, SalesLine.Type::Item);
                        SalesLine.VALIDATE("No.", Item."No.");
                        SalesLine.VALIDATE(Quantity, CustomerInvoiceStaging.Quantity);
                        SalesLine.VALIDATE("Unit Price", CustomerInvoiceStaging."Unit Price");
                        //SalesLine.VALIDATE(Amount, CustomerInvoiceStaging.Amount); SSLT

                        //SGB005
                        SalesLine.VALIDATE("Shortcut Dimension 1 Code", CustomerInvoiceStaging."Country Code");
                        //SGB005

                        SalesLine.MODIFY;
                        //SGB005
                        //SalesLine.VALIDATE("Shortcut Dimension 1 Code",CustomerInvoiceStaging."Country Code");
                        //SGB005


                        TempCustomerInvoiceStaging."Entry No." := CustomerInvoiceStaging."Entry No.";
                        TempCustomerInvoiceStaging.INSERT;

                    UNTIL CustomerInvoiceStaging.NEXT = 0;

            UNTIL TempSalesHeader.NEXT = 0;
        IF TempCustomerInvoiceStaging.FINDSET THEN
            REPEAT
                CustomerInvoiceStaging.GET(TempCustomerInvoiceStaging."Entry No.");
                CustomerInvoiceStaging.Processed := TRUE;
                CustomerInvoiceStaging."Date Processed" := CURRENTDATETIME;
                CustomerInvoiceStaging."Processed By" := USERID;
                CustomerInvoiceStaging.MODIFY;
            UNTIL TempCustomerInvoiceStaging.NEXT = 0;


        COMMIT;

        IntegrationSetup.GET;
        IF IntegrationSetup."Automatic Sales Posting" THEN BEGIN
            TempSalesHeader.RESET;
            IF TempSalesHeader.FINDSET THEN
                REPEAT
                    SalesHeader.GET(TempSalesHeader."Document Type", TempSalesHeader."No.");

                    CLEAR(SalesPost);
                    IF NOT SalesPost.RUN(SalesHeader) THEN BEGIN
                        SalesHeader."Automatic Posting Failed" := TRUE;
                        SalesHeader.MODIFY;
                    END;

                UNTIL TempSalesHeader.NEXT = 0;
        END;
    end;

    procedure CheckSalesInvoices()
    var
        CustomerInvoiceStaging: Record "Customer and Invoice Staging";
        ProcessedCustomerInvoiceStaging: Record "Customer and Invoice Staging";
        TempSalesHeader: Record "Sales Header" temporary;
        IntegrationSetup: Record "Integration Setup";
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        Item: Record Item;
        ConfigTemplateHeader: Record "Config. Template Header";
        CustomerID: Code[20];
        RecRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        TemplateCode: Code[20];
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PrevDocNo: Code[20];
        NextLineNo: Integer;
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;

        TempSalesHeader.RESET;
        TempSalesHeader.DELETEALL;

        PrevDocNo := '';

        CustomerInvoiceStaging.RESET;

        CustomerInvoiceStaging.SETRANGE(Processed, FALSE);
        CustomerInvoiceStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");


        CustomerInvoiceStaging.MODIFYALL("Has Error", FALSE);
        CustomerInvoiceStaging.MODIFYALL("Error 1", FALSE);
        CustomerInvoiceStaging.MODIFYALL("Error 2", FALSE);
        CustomerInvoiceStaging.MODIFYALL("Error 3", FALSE);
        CustomerInvoiceStaging.MODIFYALL("Error 4", FALSE);
        CustomerInvoiceStaging.MODIFYALL("Error Message", '');


        IF CustomerInvoiceStaging.FINDSET THEN
            REPEAT
                //IF STRPOS("Customer Id",' USD') > 0 THEN BEGIN
                //  CustomerID := DELCHR("Customer Id",'=',' USD');
                //END ELSE BEGIN
                //  CustomerID := "Customer Id";
                //END;
                CustomerID := CustomerInvoiceStaging."Customer Id";

                IF NOT Customer.GET(CustomerID) THEN BEGIN
                    CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, Customer.TABLECAPTION, CustomerInvoiceStaging."Customer Id");
                    CustomerInvoiceStaging."Error 1" := TRUE;
                END ELSE BEGIN
                    IF Customer."Customer Posting Group" = '' THEN BEGIN
                        CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50002, Customer.TABLECAPTION, CustomerID);
                        CustomerInvoiceStaging."Error 1" := TRUE;
                    END;
                END;

                Item.SETRANGE("Integration Item", UPPERCASE(CustomerInvoiceStaging."Item No."));
                IF NOT Item.FINDFIRST THEN BEGIN
                    CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, 'Item', CustomerInvoiceStaging."Item No.");
                    CustomerInvoiceStaging."Error 2" := TRUE;
                END;

                IF NOT ConfigTemplateHeader.GET(CustomerInvoiceStaging."Integration Currency code") THEN BEGIN
                    CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50004, CustomerInvoiceStaging."Integration Currency code");
                    CustomerInvoiceStaging."Error 3" := TRUE;
                END;

                IF NOT CustomerInvoiceStaging.Regenerated THEN BEGIN
                    ProcessedCustomerInvoiceStaging.SETRANGE(Processed, TRUE);
                    ProcessedCustomerInvoiceStaging.SETRANGE("Order Increment Id", CustomerInvoiceStaging."Order Increment Id");
                    IF ProcessedCustomerInvoiceStaging.FINDFIRST THEN BEGIN
                        CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50000, CustomerInvoiceStaging."Order Increment Id", ProcessedCustomerInvoiceStaging."Entry No.");
                        CustomerInvoiceStaging."Error 4" := TRUE;
                    END;
                END;

                CustomerInvoiceStaging.MODIFY;

                IF CustomerInvoiceStaging."Error Message" <> '' THEN BEGIN
                    TempSalesHeader."No." := CustomerInvoiceStaging."Order Increment Id";
                    IF TempSalesHeader.INSERT THEN;
                END;
            UNTIL CustomerInvoiceStaging.NEXT = 0;



        IF CustomerInvoiceStaging.FINDSET THEN
            REPEAT
                IF TempSalesHeader.GET(0, CustomerInvoiceStaging."Order Increment Id") THEN BEGIN
                    CustomerInvoiceStaging."Has Error" := TRUE;
                    CustomerInvoiceStaging.MODIFY;
                END;
            UNTIL CustomerInvoiceStaging.NEXT = 0;


        COMMIT;
    end;

    procedure CheckCashReceiptJnl()
    var
        CompanyInfo: Record "Company Information";
        IntegrationSetup: Record "Integration Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        CustomePaymentStaging: Record "Customer Cash Receipt Staging";
        ProcessedCustomePaymentStaging: Record "Customer Cash Receipt Staging";
        PaymentTypeMapping: Record "Payment Type Mapping";
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        GLSetup: Record "General Ledger Setup";
        NextLineNo: Integer;
        i: Integer;
        CustomerID: Code[20];
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        GLSetup.GET;

        IntegrationSetup.GET;
        //IF NOT CONFIRM(Text50005,FALSE,IntegrationSetup."Cash Receipt Batch") THEN BEGIN
        //  MESSAGE(Text50002);
        //  EXIT
        //END;

        //DialogWindow.OPEN(Text50003);
        CustomePaymentStaging.RESET;

        CustomePaymentStaging.SETRANGE(Processed, FALSE);
        CustomePaymentStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");


        CustomePaymentStaging.MODIFYALL("Has Error", FALSE);
        CustomePaymentStaging.MODIFYALL("Error 1", FALSE);
        CustomePaymentStaging.MODIFYALL("Error 2", FALSE);
        CustomePaymentStaging.MODIFYALL("Error 3", FALSE);
        CustomePaymentStaging.MODIFYALL("Error 4", FALSE);
        CustomePaymentStaging.MODIFYALL("Error Message", '');


        IF CustomePaymentStaging.FINDSET THEN
            REPEAT
                CustomerID := CustomePaymentStaging."Customer Id";

                IF NOT Customer.GET(CustomerID) THEN BEGIN
                    CLEAR(Customer);
                    CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50001, CustomePaymentStaging."Customer Id");
                    CustomePaymentStaging."Error 1" := TRUE;
                END ELSE BEGIN
                    IF Customer."Customer Posting Group" = '' THEN BEGIN
                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50002);
                        CustomePaymentStaging."Error 1" := TRUE;
                    END;
                END;

                IF NOT PaymentTypeMapping.GET(UPPERCASE(CustomePaymentStaging."Payment Type"), CustomePaymentStaging."Integration Currency Code") THEN BEGIN
                    CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50003, CustomePaymentStaging."Payment Type");
                    CustomePaymentStaging."Error 3" := TRUE;
                END ELSE BEGIN
                    CASE PaymentTypeMapping."NAV Type" OF
                        PaymentTypeMapping."NAV Type"::"G/L Account":
                            ; //
                        PaymentTypeMapping."NAV Type"::"Bank Account":
                            BEGIN
                                BankAccount.GET(PaymentTypeMapping."NAV No.");
                                IF Customer."Currency Code" <> BankAccount."Currency Code" THEN BEGIN
                                    CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50009, Customer.TABLECAPTION, BankAccount.TABLECAPTION);
                                    CustomePaymentStaging."Error 3" := TRUE;
                                END;
                                IF CustomePaymentStaging."Integration Currency Code" = GLSetup."LCY Code" THEN BEGIN
                                    IF Customer."Currency Code" <> '' THEN BEGIN
                                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50009, Customer.TABLECAPTION, 'Currency Code');
                                        CustomePaymentStaging."Error 3" := TRUE;
                                    END;
                                END;
                            END;
                    END;
                END;
                IF CustomePaymentStaging."Order Increment Id" <> '' THEN BEGIN
                    OldCustLedgEntry.RESET;
                    OldCustLedgEntry.SETCURRENTKEY("Document No.");
                    // OldCustLedgEntry.SETFILTER("Posting Date", '..%1',"Posting Date");

                    OldCustLedgEntry.SETRANGE("Document No.", CustomePaymentStaging."Order Increment Id");
                    OldCustLedgEntry.SETRANGE("Document Type", OldCustLedgEntry."Document Type"::Invoice);
                    OldCustLedgEntry.SETRANGE("Customer No.", CustomePaymentStaging."Customer Id");
                    OldCustLedgEntry.SETRANGE(Open, TRUE);

                    IF NOT OldCustLedgEntry.FINDFIRST THEN BEGIN
                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50012);
                        CustomePaymentStaging."Error 4" := TRUE;
                    END
                END;

                IF CustomePaymentStaging."Order Increment Id" <> '' THEN BEGIN
                    OldCustLedgEntry.RESET;
                    OldCustLedgEntry.SETCURRENTKEY("Document No.");
                    OldCustLedgEntry.SETFILTER("Posting Date", '..%1', CustomePaymentStaging."Posting Date");

                    OldCustLedgEntry.SETRANGE("Document No.", CustomePaymentStaging."Order Increment Id");
                    OldCustLedgEntry.SETRANGE("Document Type", OldCustLedgEntry."Document Type"::Invoice);
                    OldCustLedgEntry.SETRANGE("Customer No.", CustomePaymentStaging."Customer Id");
                    OldCustLedgEntry.SETRANGE(Open, TRUE);

                    IF NOT OldCustLedgEntry.FINDFIRST THEN BEGIN
                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50013);
                        CustomePaymentStaging."Error 4" := TRUE;
                    END
                END;


                /*ProcessedCustomePaymentStaging.SETRANGE(Processed,TRUE);
                ProcessedCustomePaymentStaging.SETRANGE("Customer Id","Customer Id");
                ProcessedCustomePaymentStaging.SETRANGE("Order Increment Id","Order Increment Id");
                IF NOT ProcessedCustomePaymentStaging.ISEMPTY THEN BEGIN
                  "Error Message" := STRSUBSTNO(Text50007,"Customer Id",ProcessedCustomePaymentStaging."Entry No.");
                  "Error 4" := TRUE;
                END;
                */

                IF CustomePaymentStaging."Error Message" = '' THEN
                    CustomePaymentStaging."Has Error" := FALSE
                ELSE
                    CustomePaymentStaging."Has Error" := TRUE;

                CustomePaymentStaging.MODIFY;

            UNTIL CustomePaymentStaging.NEXT = 0;



        //DialogWindow.CLOSE;

        //MESSAGE(Text50004,i,IntegrationSetup."Payroll Journal Batch");

    end;

    procedure CreateCashReceiptJnl()
    var
        CompanyInfo: Record "Company Information";
        IntegrationSetup: Record "Integration Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        CustomePaymentStaging: Record "Customer Cash Receipt Staging";
        TempCustomePaymentStaging: Record "Customer Cash Receipt Staging" temporary;
        PaymentTypeMapping: Record "Payment Type Mapping";
        GLSetup: Record "General Ledger Setup";
        NextLineNo: Integer;
        i: Integer;
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;
        IF NOT CONFIRM(Text50005, FALSE, IntegrationSetup."Cash Receipt Batch") THEN BEGIN
            MESSAGE(Text50006);
            EXIT
        END;

        //DialogWindow.OPEN(Text50003);
        GLSetup.GET;

        GenJournalTemplate.SETRANGE("Page ID", 255);
        GenJournalTemplate.FINDFIRST;
        GenJnlLine.SETRANGE("Journal Template Name", GenJournalTemplate.Name);
        GenJnlLine.SETRANGE("Journal Batch Name", IntegrationSetup."Cash Receipt Batch");
        IF GenJnlLine.FINDLAST THEN
            NextLineNo := GenJnlLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        TempCustomePaymentStaging.RESET;
        TempCustomePaymentStaging.DELETEALL;

        i := 0;
        CustomePaymentStaging.RESET;

        CustomePaymentStaging.SETRANGE(Processed, FALSE);
        CustomePaymentStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");
        CustomePaymentStaging.SETRANGE("Has Error", FALSE);




        IF CustomePaymentStaging.FINDSET THEN
            REPEAT
                GenJnlLine.INIT;
                GenJnlLine.VALIDATE("Journal Template Name", GenJournalTemplate.Name);
                GenJnlLine.VALIDATE("Journal Batch Name", IntegrationSetup."Cash Receipt Batch");
                GenJnlLine."Line No." := NextLineNo;
                GenJnlLine."Created from Integration" := TRUE;
                GenJnlLine.INSERT(TRUE);
                NextLineNo += 10000;

                GenJnlLine.VALIDATE("Posting Date", CustomePaymentStaging."Posting Date");

                GenJnlLine.VALIDATE("Document Type", GenJnlLine."Document Type"::Payment);
                GenJnlLine.VALIDATE("Document No.", CustomePaymentStaging."Document No.");
                GenJnlLine.VALIDATE("Account Type", GenJnlLine."Account Type"::Customer);
                GenJnlLine.VALIDATE("Account No.", CustomePaymentStaging."Customer Id");
                GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice);
                GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.", CustomePaymentStaging."Order Increment Id");

                GenJnlLine.Description := COPYSTR(CustomePaymentStaging."Payment Type" + ' ' + GenJnlLine."Account No.", 1, 50);
                IF CustomePaymentStaging."Integration Currency Code" <> GLSetup."LCY Code" THEN BEGIN
                    GenJnlLine.VALIDATE("Currency Code", CustomePaymentStaging."Integration Currency Code");
                    GenJnlLine.VALIDATE("Currency Factor", ROUND(1 / CustomePaymentStaging."Exchange Rate", 0.00001));
                END;


                GenJnlLine.VALIDATE(Amount, -CustomePaymentStaging.Amount);
                GenJnlLine.VALIDATE("Applies-to Doc. No.", '');
                GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice);
                GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.", CustomePaymentStaging."Order Increment Id");

                PaymentTypeMapping.GET(UPPERCASE(CustomePaymentStaging."Payment Type"), CustomePaymentStaging."Integration Currency Code");
                CASE PaymentTypeMapping."NAV Type" OF
                    PaymentTypeMapping."NAV Type"::"G/L Account":
                        GenJnlLine.VALIDATE("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                    PaymentTypeMapping."NAV Type"::"Bank Account":
                        GenJnlLine.VALIDATE("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
                END;

                GenJnlLine.VALIDATE("Bal. Account No.", PaymentTypeMapping."NAV No.");

                GenJnlLine.MODIFY;

                TempCustomePaymentStaging := CustomePaymentStaging;
                TempCustomePaymentStaging.INSERT;

            UNTIL CustomePaymentStaging.NEXT = 0;


        IF TempCustomePaymentStaging.FINDSET THEN
            REPEAT
                CustomePaymentStaging.GET(TempCustomePaymentStaging."Entry No.");
                CustomePaymentStaging.Processed := TRUE;
                CustomePaymentStaging."Date Processed" := CURRENTDATETIME;
                CustomePaymentStaging."Processed By" := USERID;
                CustomePaymentStaging.MODIFY;

            UNTIL TempCustomePaymentStaging.NEXT = 0;

        //DialogWindow.CLOSE;

        //MESSAGE(Text50004,i,IntegrationSetup."Payroll Journal Batch");
    end;

    procedure CreatePurchInvoices()
    var
        VendorInvoiceStaging: Record "Purchase Invoice Staging";
        TempPurchHeader: Record "Purchase Header" temporary;
        TempVendorInvoiceStaging: Record "Purchase Invoice Staging" temporary;
        IntegrationSetup: Record "Integration Setup";
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        Item: Record Item;
        ConfigTemplateHeader: Record "Config. Template Header";
        CompanyInfo: Record "Company Information";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        SalesPost: Codeunit "Sales-Post";
        VendorID: Code[20];
        RecRef: RecordRef;
        TemplateCode: Code[20];
        PrevDocNo: Code[20];
        NextLineNo: Integer;
        GLSetup: Record "General Ledger Setup";
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");
        GLSetup.GET;

        IntegrationSetup.GET;

        TempPurchHeader.RESET;
        TempPurchHeader.DELETEALL;

        TempVendorInvoiceStaging.RESET;
        TempVendorInvoiceStaging.DELETEALL;

        PrevDocNo := '';


        VendorInvoiceStaging.SETCURRENTKEY("Purchase From", Processed);

        VendorInvoiceStaging.SETRANGE(Processed, FALSE);
        VendorInvoiceStaging.SETRANGE("Purchase From", CompanyInfo."Shipped From");
        VendorInvoiceStaging.SETRANGE("Has Error", FALSE);

        IF VendorInvoiceStaging.FINDSET THEN
            REPEAT
                IF VendorInvoiceStaging.Contract <> PrevDocNo THEN BEGIN
                    TempPurchHeader."Document Type" := TempPurchHeader."Document Type"::Invoice;
                    TempPurchHeader."No." := VendorInvoiceStaging.Contract;
                    TempPurchHeader."Buy-from Vendor No." := VendorInvoiceStaging."Seller Id";
                    TempPurchHeader."Currency Factor" := VendorInvoiceStaging."Exchange Rate";
                    TempPurchHeader."Posting Date" := VendorInvoiceStaging."Date Received";
                    IF VendorInvoiceStaging."Integration Currency code" <> GLSetup."LCY Code" THEN
                        TempPurchHeader."Currency Code" := VendorInvoiceStaging."Integration Currency code"
                    ELSE
                        TempPurchHeader."Currency Code" := '';


                    IF TempPurchHeader.INSERT THEN;

                    PrevDocNo := VendorInvoiceStaging.Contract;
                END;
            UNTIL VendorInvoiceStaging.NEXT = 0;



        TempPurchHeader.RESET;
        IF TempPurchHeader.FINDSET THEN
            REPEAT
                VendorID := TempPurchHeader."Buy-from Vendor No.";

                PurchHeader.INIT;
                PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
                PurchHeader.VALIDATE("No.", TempPurchHeader."No.");
                PurchHeader.VALIDATE("Buy-from Vendor No.", VendorID);
                PurchHeader.SetHideValidationDialog(true);
                PurchHeader.VALIDATE("Posting Date", TempPurchHeader."Posting Date");

                PurchHeader."Posting No." := PurchHeader."No.";
                PurchHeader."Posting Description" := TempPurchHeader."No.";
                PurchHeader."Vendor Invoice No." := TempPurchHeader."No.";

                PurchHeader."Created from Integration" := TRUE;
                PurchHeader.VALIDATE("Currency Code", TempPurchHeader."Currency Code");

                IF TempPurchHeader."Currency Factor" = 0 then
                    TempPurchHeader."Currency Factor" := 1;

                PurchHeader."Currency Factor" := 1 / TempPurchHeader."Currency Factor";


                PurchHeader.INSERT(TRUE);

                PurchHeader.VALIDATE("Document Date", TempPurchHeader."Posting Date");
                PurchHeader.Modify(TRUE);

                NextLineNo := 0;
                VendorInvoiceStaging.SETRANGE(Contract, TempPurchHeader."No.");
                IF VendorInvoiceStaging.FINDSET THEN
                    REPEAT
                        PurchLine.INIT;
                        PurchLine."Document Type" := PurchHeader."Document Type";
                        PurchLine."Document No." := PurchHeader."No.";
                        NextLineNo += 10000;
                        PurchLine."Line No." := NextLineNo;

                        PurchLine.INSERT(TRUE);

                        Item.SETRANGE("Integration Item", UPPERCASE(VendorInvoiceStaging."Item No."));
                        Item.FINDFIRST;

                        PurchLine.VALIDATE(Type, PurchLine.Type::Item);
                        PurchLine.VALIDATE("No.", Item."No.");

                        //SGB006
                        PurchLine.Description := VendorInvoiceStaging.Description;
                        //SGB006

                        PurchLine.VALIDATE(Quantity, VendorInvoiceStaging.Quantity);
                        /*PurchLine."Line Amount" := ROUND(VendorInvoiceStaging.SubTotal, 0.01); Old Code
                        PurchLine."Direct Unit Cost" := ROUND(VendorInvoiceStaging.SubTotal / VendorInvoiceStaging.Quantity, 0.01);*/
                        PurchLine.validate("Direct Unit Cost", VendorInvoiceStaging.Cost); //New SSLT Code


                        PurchLine.MODIFY;

                        TempVendorInvoiceStaging."Entry No." := VendorInvoiceStaging."Entry No.";
                        TempVendorInvoiceStaging.INSERT;

                    UNTIL VendorInvoiceStaging.NEXT = 0;

            UNTIL TempPurchHeader.NEXT = 0;

        IF TempVendorInvoiceStaging.FINDSET THEN
            REPEAT
                VendorInvoiceStaging.GET(TempVendorInvoiceStaging."Entry No.");
                VendorInvoiceStaging.Processed := TRUE;
                VendorInvoiceStaging."Date Processed" := CURRENTDATETIME;
                VendorInvoiceStaging."Processed By" := USERID;
                VendorInvoiceStaging.MODIFY;
            UNTIL TempVendorInvoiceStaging.NEXT = 0;


        COMMIT;
    end;

    procedure CheckPurchInvoices(ShowMessage: Boolean)
    var
        VendorInvoiceStaging: Record "Purchase Invoice Staging";
        ProcessedVendorInvoiceStaging: Record "Purchase Invoice Staging";
        TempPurchHeader: Record "Purchase Header" temporary;
        IntegrationSetup: Record "Integration Setup";
        Vendor: Record Vendor;
        TempVendor: Record Vendor temporary;
        Item: Record Item;
        ConfigTemplateHeader: Record "Config. Template Header";
        VendorID: Code[20];
        RecRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        TemplateCode: Code[20];
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PrevDocNo: Code[20];
        NextLineNo: Integer;
        CompanyInfo: Record "Company Information";
        TotalLine: Integer;
        ErrorLine: Integer;
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");
        GLSetup.GET;

        IntegrationSetup.GET;

        TempPurchHeader.RESET;
        TempPurchHeader.DELETEALL;

        PrevDocNo := '';

        VendorInvoiceStaging.RESET;

        VendorInvoiceStaging.SETRANGE(Processed, FALSE);
        VendorInvoiceStaging.SETRANGE("Purchase From", CompanyInfo."Shipped From");


        VendorInvoiceStaging.MODIFYALL("Has Error", FALSE);
        VendorInvoiceStaging.MODIFYALL("Error 1", FALSE);
        VendorInvoiceStaging.MODIFYALL("Error 2", FALSE);
        VendorInvoiceStaging.MODIFYALL("Error 3", FALSE);
        VendorInvoiceStaging.MODIFYALL("Error 4", FALSE);
        VendorInvoiceStaging.MODIFYALL("Error Message", '');
        TotalLine := VendorInvoiceStaging.COUNT;
        ErrorLine := 0;


        IF VendorInvoiceStaging.FINDSET THEN
            REPEAT

                VendorID := VendorInvoiceStaging."Seller Id";

                IF NOT Vendor.GET(VendorID) THEN BEGIN
                    VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, Vendor.TABLECAPTION, VendorInvoiceStaging."Seller Id");
                    VendorInvoiceStaging."Error 1" := TRUE;
                END ELSE BEGIN
                    IF Vendor."Vendor Posting Group" = '' THEN BEGIN
                        VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50002, Vendor.TABLECAPTION, VendorID);
                        VendorInvoiceStaging."Error 1" := TRUE;
                    END;
                END;

                Item.SETRANGE("Integration Item", UPPERCASE(VendorInvoiceStaging."Item No."));
                IF NOT Item.FINDFIRST THEN BEGIN
                    VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, Item.TABLECAPTION, VendorInvoiceStaging."Item No.");
                    VendorInvoiceStaging."Error 2" := TRUE;
                END;

                //IF NOT ConfigTemplateHeader.GET("Integration Currency code") THEN BEGIN
                //  "Error Message" := STRSUBSTNO(Text50004,"Integration Currency code");
                //  "Error 3" := TRUE;
                //END;

                IF NOT VendorInvoiceStaging.Regenerated THEN BEGIN
                    ProcessedVendorInvoiceStaging.SETRANGE(Processed, TRUE);
                    ProcessedVendorInvoiceStaging.SETRANGE("Seller Id", VendorInvoiceStaging."Seller Id");
                    ProcessedVendorInvoiceStaging.SETRANGE(Contract, VendorInvoiceStaging.Contract);


                    IF ProcessedVendorInvoiceStaging.FINDFIRST THEN BEGIN
                        VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50000, VendorInvoiceStaging.Contract, ProcessedVendorInvoiceStaging."Entry No.");
                        VendorInvoiceStaging."Error 4" := TRUE;
                    END;
                END;

                if VendorInvoiceStaging."Purchase From" = 'US' then
                    if VendorInvoiceStaging."Integration Currency code" = 'CAD' then begin
                        VendorInvoiceStaging."Error 5" := true;
                        VendorInvoiceStaging."Error Message" := 'Check Magento Order';
                    end;

                VendorInvoiceStaging.MODIFY;

                IF VendorInvoiceStaging."Error Message" <> '' THEN BEGIN
                    TempPurchHeader."No." := VendorInvoiceStaging.Contract;
                    TempPurchHeader."Buy-from Vendor No." := VendorID;
                    IF TempPurchHeader.INSERT THEN;

                    ErrorLine += 1;
                END;
            UNTIL VendorInvoiceStaging.NEXT = 0;



        IF VendorInvoiceStaging.FINDSET THEN
            REPEAT
                TempPurchHeader.SETRANGE("No.", VendorInvoiceStaging.Contract);
                TempPurchHeader.SETRANGE("Buy-from Vendor No.", VendorID);
                IF TempPurchHeader.FINDFIRST THEN BEGIN
                    VendorInvoiceStaging."Has Error" := TRUE;
                    VendorInvoiceStaging.MODIFY;
                END;
            UNTIL VendorInvoiceStaging.NEXT = 0;


        COMMIT;

        IF ShowMessage THEN
            MESSAGE(Text50010, TotalLine, ErrorLine);
    end;

    procedure ReGenerateCustomerandInvoiceStaging(var LocalCustomerInvoiceStaging: Record "Customer and Invoice Staging")
    var
        CustomerInvoiceStaging: Record "Customer and Invoice Staging";
        ProcessedCustomerInvoiceStaging: Record "Customer and Invoice Staging";
        TempSalesHeader: Record "Sales Header" temporary;
        PrevDocNo: Code[20];
    begin
        TempSalesHeader.RESET;
        TempSalesHeader.DELETEALL;

        PrevDocNo := '';


        IF LocalCustomerInvoiceStaging.FINDSET THEN
            REPEAT
                IF LocalCustomerInvoiceStaging."Order Increment Id" <> PrevDocNo THEN BEGIN
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Invoice;
                    TempSalesHeader."No." := LocalCustomerInvoiceStaging."Order Increment Id";
                    TempSalesHeader."Sell-to Customer No." := LocalCustomerInvoiceStaging."Customer Id";
                    TempSalesHeader."Currency Factor" := LocalCustomerInvoiceStaging."Exchange Rate";
                    TempSalesHeader."Posting Date" := LocalCustomerInvoiceStaging."Invoice Date";

                    IF TempSalesHeader.INSERT THEN;

                    PrevDocNo := LocalCustomerInvoiceStaging."Order Increment Id";
                END;
            UNTIL LocalCustomerInvoiceStaging.NEXT = 0;


        TempSalesHeader.RESET;
        IF TempSalesHeader.FINDSET THEN
            REPEAT
                CustomerInvoiceStaging.INIT;
                CustomerInvoiceStaging."Order Increment Id" := TempSalesHeader."No.";
                CustomerInvoiceStaging."Customer Id" := TempSalesHeader."Sell-to Customer No.";

                ReGenerateCustomerandInvoice(CustomerInvoiceStaging)

            UNTIL TempSalesHeader.NEXT = 0;
    end;

    procedure ReGenerateCustomerandInvoice(LocalCustomerInvoiceStaging: Record "Customer and Invoice Staging")
    var
        CustomerInvoiceStaging: Record "Customer and Invoice Staging";
        ProcessedCustomerInvoiceStaging: Record "Customer and Invoice Staging";
    begin
        ProcessedCustomerInvoiceStaging.RESET;
        ProcessedCustomerInvoiceStaging.SETRANGE(Processed, TRUE);
        ProcessedCustomerInvoiceStaging.SETRANGE("Order Increment Id", LocalCustomerInvoiceStaging."Order Increment Id");
        ProcessedCustomerInvoiceStaging.SETRANGE("Customer Id", LocalCustomerInvoiceStaging."Customer Id");
        IF ProcessedCustomerInvoiceStaging.FINDSET THEN
            REPEAT
                CustomerInvoiceStaging.INIT;

                CustomerInvoiceStaging := ProcessedCustomerInvoiceStaging;

                CustomerInvoiceStaging."Entry No." := 0;
                CustomerInvoiceStaging.Processed := FALSE;
                CustomerInvoiceStaging."Date Processed" := 0DT;
                CustomerInvoiceStaging."Processed By" := '';
                CustomerInvoiceStaging."Has Error" := FALSE;
                CustomerInvoiceStaging."Error 1" := FALSE;
                CustomerInvoiceStaging."Error 2" := FALSE;
                CustomerInvoiceStaging."Error 3" := FALSE;
                CustomerInvoiceStaging."Error 4" := FALSE;
                CustomerInvoiceStaging."Error Message" := '';
                CustomerInvoiceStaging.Regenerated := TRUE;
                CustomerInvoiceStaging."Regenerated from Entry No." := ProcessedCustomerInvoiceStaging."Entry No.";

                CustomerInvoiceStaging.INSERT(TRUE);
            UNTIL ProcessedCustomerInvoiceStaging.NEXT = 0;
    end;

    procedure ReGeneratePurchInvoiceStaging(var LocalPurchInvoiceStaging: Record "Purchase Invoice Staging")
    var
        PurchInvoiceStaging: Record "Purchase Invoice Staging";
        ProcessedPurchInvoiceStaging: Record "Purchase Invoice Staging";
        TempPurchHeader: Record "Purchase Header" temporary;
        PrevDocNo: Code[20];
    begin
        TempPurchHeader.RESET;
        TempPurchHeader.DELETEALL;

        PrevDocNo := '';


        IF LocalPurchInvoiceStaging.FINDSET THEN
            REPEAT
                IF LocalPurchInvoiceStaging.Contract <> PrevDocNo THEN BEGIN
                    TempPurchHeader."Document Type" := TempPurchHeader."Document Type"::Invoice;
                    TempPurchHeader."No." := LocalPurchInvoiceStaging.Contract;
                    TempPurchHeader."Buy-from Vendor No." := LocalPurchInvoiceStaging."Seller Id";
                    TempPurchHeader."Currency Factor" := LocalPurchInvoiceStaging."Exchange Rate";
                    TempPurchHeader."Posting Date" := LocalPurchInvoiceStaging."Date Received";
                    IF LocalPurchInvoiceStaging."Integration Currency code" <> GLSetup."LCY Code" THEN
                        TempPurchHeader."Currency Code" := LocalPurchInvoiceStaging."Integration Currency code"
                    ELSE
                        TempPurchHeader."Currency Code" := '';

                    IF TempPurchHeader.INSERT THEN;

                    PrevDocNo := LocalPurchInvoiceStaging.Contract;
                END;
            UNTIL LocalPurchInvoiceStaging.NEXT = 0;



        TempPurchHeader.RESET;
        IF TempPurchHeader.FINDSET THEN
            REPEAT

                PurchInvoiceStaging.INIT;
                PurchInvoiceStaging.Contract := TempPurchHeader."No.";
                PurchInvoiceStaging."Seller Id" := TempPurchHeader."Buy-from Vendor No.";

                ReGeneratePurchInvoice(PurchInvoiceStaging)
            UNTIL TempPurchHeader.NEXT = 0;
    end;

    procedure ReGeneratePurchInvoice(LocalPurchInvoiceStaging: Record "Purchase Invoice Staging")
    var
        PurchInvoiceStaging: Record "Purchase Invoice Staging";
        ProcessedPurchInvoiceStaging: Record "Purchase Invoice Staging";
    begin
        ProcessedPurchInvoiceStaging.RESET;
        ProcessedPurchInvoiceStaging.SETRANGE(Processed, TRUE);
        ProcessedPurchInvoiceStaging.SETRANGE(Contract, LocalPurchInvoiceStaging.Contract);
        ProcessedPurchInvoiceStaging.SETRANGE("Seller Id", LocalPurchInvoiceStaging."Seller Id");
        IF ProcessedPurchInvoiceStaging.FINDSET THEN
            REPEAT
                PurchInvoiceStaging.INIT;

                PurchInvoiceStaging := ProcessedPurchInvoiceStaging;

                PurchInvoiceStaging."Entry No." := 0;
                PurchInvoiceStaging.Processed := FALSE;
                PurchInvoiceStaging."Date Processed" := 0DT;
                PurchInvoiceStaging."Processed By" := '';
                PurchInvoiceStaging."Has Error" := FALSE;
                PurchInvoiceStaging."Error 1" := FALSE;
                PurchInvoiceStaging."Error 2" := FALSE;
                PurchInvoiceStaging."Error 3" := FALSE;
                PurchInvoiceStaging."Error 4" := FALSE;
                PurchInvoiceStaging."Error Message" := '';
                PurchInvoiceStaging.Regenerated := TRUE;
                PurchInvoiceStaging."Regenerated from Entry No." := ProcessedPurchInvoiceStaging."Entry No.";

                PurchInvoiceStaging.INSERT(TRUE);
            UNTIL ProcessedPurchInvoiceStaging.NEXT = 0;
    end;

    procedure ReGenerateCashReceiptStaging(var LocalCashReceiptStaging: Record "Customer Cash Receipt Staging")
    var
        CashReceiptStaging: Record "Customer Cash Receipt Staging";
    begin

        IF LocalCashReceiptStaging.FINDSET THEN
            REPEAT
                CashReceiptStaging.INIT;

                CashReceiptStaging := LocalCashReceiptStaging;

                CashReceiptStaging."Entry No." := 0;
                CashReceiptStaging.Processed := FALSE;
                CashReceiptStaging."Date Processed" := 0DT;
                CashReceiptStaging."Processed By" := '';
                CashReceiptStaging."Has Error" := FALSE;
                CashReceiptStaging."Error 1" := FALSE;
                CashReceiptStaging."Error 2" := FALSE;
                CashReceiptStaging."Error 3" := FALSE;
                CashReceiptStaging."Error 4" := FALSE;
                CashReceiptStaging."Error Message" := '';
                CashReceiptStaging.Regenerated := TRUE;
                CashReceiptStaging."Regenerated from Entry No." := LocalCashReceiptStaging."Entry No.";

                CashReceiptStaging.INSERT(TRUE);

            UNTIL LocalCashReceiptStaging.NEXT = 0;
    end;
}
