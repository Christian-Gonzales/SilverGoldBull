codeunit 50000 "SGB Integration Management"
{
    // SGB001  YD  20150901  Start
    // SGB002  YD  20151120  Add three functions ReGenerateCustomerandInvoiceStaging,ReGeneratePurchInvoiceStaging,ReGenerateCashReceiptStaging
    // SGB003  YD  20160115  Apply Template to new customer only
    // SGB005  YD  20160825  Add new field CustomerInvoiceStaging."Country Code"
    // SGB006  YD  20180927  Get Dwscription from staging PurchLine.Description := VendorInvoiceStaging.Description;
    // PTC001
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
        Text50013: Label 'Payment Date is earlier than the invoice Date.';
        Text50014: Label 'The order %1 was imported with Entry No. %2.';
        Text50015: Label 'Do you want to create customer and sales order?';
        Text50016: Label 'The quantity does not match the original quantity. Order No.: %1 | Integration Item: %2 | Item No.: %3';
        WithAppliedEntries: boolean;

    procedure CheckSales()
    begin
        CheckSalesInvoices(true);
    end;

    procedure SalesProcess()
    begin
        ToCreateItem := true;
        CreateCustomers(0);
        CheckSalesInvoices(false);
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

        ToCreateItem := true;
        CheckPurchInvoices(FALSE);
        CreatePurchInvoices();
    end;

    procedure CreateCustomers(Type: Integer)
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
        CustCashRcptStaging: Record "Cust Cash Rcpt Staging v2";
    begin
        //Type added 0 - orginal code, 1 - for payment customers
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;

        TempCustomer.RESET;
        TempCustomer.DELETEALL;

        if Type = 0 then begin //Original Code - looking into Invoice staging table
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

                            OnAfterInsertCustomer_CreateCustomers(CustomeInvoiceStaging);

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
        end else
            if Type = 1 then begin //For Cash receipt staging v2 new customers 
                CustCashRcptStaging.SETCURRENTKEY("Shipped From", Processed);
                CustCashRcptStaging.SETRANGE(Processed, FALSE);
                CustCashRcptStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");

                IF CustCashRcptStaging.FINDSET THEN
                    REPEAT

                        CustomerID := CustCashRcptStaging."Customer Id";
                        TemplateCode := CustCashRcptStaging."Integration Currency code";

                        IF NOT TempCustomer.GET(CustomerID) THEN BEGIN
                            IF Customer.GET(CustomerID) THEN BEGIN
                                Customer.VALIDATE(Name, CustCashRcptStaging."Customer Name");
                                Customer.MODIFY;
                            END ELSE BEGIN
                                Customer.INIT;
                                Customer."No." := CustomerID;
                                Customer.VALIDATE(Name, CustCashRcptStaging."Customer Name");
                                Customer.INSERT(TRUE);

                                OnAfterInsertCustomer_CreateCustomers(CustomeInvoiceStaging);

                                TempCustomer := Customer;
                                TempCustomer.INSERT;

                                RecRef.GETTABLE(Customer);
                                ConfigTemplateHeader.GET(TemplateCode);
                                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                            END;
                        END ELSE BEGIN
                            Customer.GET(CustomerID)
                        END;
                    UNTIL CustCashRcptStaging.NEXT = 0;
            end;


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
        HandleSalesLineNoValidation: Boolean;
        GLAcc: record "G/L Account";
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
                IF CustomerInvoiceStaging."Shipment Increment Id" <> PrevDocNo THEN BEGIN  // IF CustomerInvoiceStaging."Order Increment Id" <> PrevDocNo THEN BEGIN
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Invoice;
                    TempSalesHeader."Document Date" := CustomerInvoiceStaging."Invoice Date";
                    TempSalesHeader."No." := CustomerInvoiceStaging."Shipment Increment Id";    // TempSalesHeader."No." := CustomerInvoiceStaging."Order Increment Id";
                    TempSalesHeader."Sell-to Customer No." := CustomerInvoiceStaging."Customer Id";
                    TempSalesHeader."Currency Factor" := CustomerInvoiceStaging."Exchange Rate";
                    TempSalesHeader."Posting Date" := CustomerInvoiceStaging."Shipment Date";   // TempSalesHeader."Posting Date" := CustomerInvoiceStaging."Invoice Date";
                    TempSalesHeader."External Document No." := CustomerInvoiceStaging."Order Increment Id"; // TempSalesHeader."External Document No." := CustomerInvoiceStaging."External Document No."; //SSLT 09-27-21

                    //SGB005
                    //TempSalesHeader."Shortcut Dimension 1 Code" := CustomerInvoiceStaging."Country Code"; //PTC001
                    //SGB005
                    IF TempSalesHeader.INSERT THEN;

                    PrevDocNo := CustomerInvoiceStaging."Shipment Increment Id";    // PrevDocNo := CustomerInvoiceStaging."Order Increment Id";
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
                SalesHeader."External Document No." := TempSalesHeader."External Document No."; //SSLT 09-27-21
                IF CustomerInvoiceStaging."Integration Currency code" <> GLSetup."LCY Code" THEN
                    TempSalesHeader."Currency Code" := CustomerInvoiceStaging."Integration Currency code"
                ELSE
                    TempSalesHeader."Currency Code" := '';

                //SGB005
                //SalesHeader.VALIDATE("Shortcut Dimension 1 Code",TempSalesHeader."Shortcut Dimension 1 Code");//PTC001
                //SGB005

                SalesHeader.INSERT(TRUE);


                //SGB005

                SalesHeader.GET(SalesHeader."Document Type"::Invoice, TempSalesHeader."No.");
                //SalesHeader.INIT;
                //SalesHeader.VALIDATE("Shortcut Dimension 1 Code", TempSalesHeader."Shortcut Dimension 1 Code");//PTC001
                SalesHeader.VALIDATE("Document Date", TempSalesHeader."Posting Date");
                SalesHeader.MODIFY;
                //SGB005

                NextLineNo := 0;
                CustomerInvoiceStaging.SETRANGE("Shipment Increment Id", TempSalesHeader."No.");   // CustomerInvoiceStaging.SETRANGE("Order Increment Id", TempSalesHeader."No.");
                IF CustomerInvoiceStaging.FINDSET THEN
                    REPEAT
                        SalesLine.INIT;
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        NextLineNo += 10000;
                        SalesLine."Line No." := NextLineNo;

                        SalesLine.INSERT(TRUE);
                        OnBeforeValidateSalesLineNo_CreateSalesInvoices(CustomerInvoiceStaging, SalesLine, HandleSalesLineNoValidation);
                        Case CustomerInvoiceStaging.Type of
                            CustomerInvoiceStaging.Type::Item:
                                BEGIN
                                    if not HandleSalesLineNoValidation then begin
                                        Item.SETRANGE("Integration Item", UPPERCASE(CustomerInvoiceStaging."Item No."));
                                        if Item.IsEmpty then
                                            CreateItem(UPPERCASE(CustomerInvoiceStaging."Item No."), CustomerInvoiceStaging.Description, CustomerInvoiceStaging."Base Unit of Measure", CustomerInvoiceStaging."Gen. Product Posting Group", CustomerInvoiceStaging."Inventory Posting Group");
                                        Item.FINDFIRST;

                                        SalesLine.VALIDATE(Type, SalesLine.Type::Item);
                                        SalesLine.VALIDATE("No.", Item."No.");
                                    end;
                                End;
                            CustomerInvoiceStaging.Type::"G/L Account":
                                BEGIN
                                    SalesLine.VALIDATE(Type, SalesLine.Type::"G/L Account");
                                    SalesLine.VALIDATE("No.", CustomerInvoiceStaging."Item No.");
                                END
                        end;


                        SalesLine.VALIDATE(Quantity, CustomerInvoiceStaging.Quantity);
                        SalesLine.VALIDATE("Unit Price", CustomerInvoiceStaging."Unit Price");
                        //<<PTC001
                        SalesLine."PNR No." := CustomerInvoiceStaging."PNR No.";
                        SalesLine."Booking Ref. No" := CustomerInvoiceStaging."Booking Ref. No";
                        SalesLine."Passenger Name" := CustomerInvoiceStaging."Passenger Name";

                        SalesLine.Validate("WHT Business Posting Group", CustomerInvoiceStaging."WHT Bus. Posting Group");
                        SalesLine.Validate("WHT Product Posting Group", CustomerInvoiceStaging."WHT Product Posting Group");

                        AssignDimensionSalesLine(SalesLine, 'CLIENTTYPE', CustomerInvoiceStaging."Client Type Code(Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'COSTCATEGORY', CustomerInvoiceStaging."Cost Category (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'COSTCENTER', CustomerInvoiceStaging."Client Type Code(Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'OFFICELOCATION', CustomerInvoiceStaging."Office Location (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'PRINCIPAL', CustomerInvoiceStaging."Principal (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'PRODUCTTYPE', CustomerInvoiceStaging."Product Type (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'PROFITCENTER', CustomerInvoiceStaging."Profit Center (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'SFCODE', CustomerInvoiceStaging."SF Code (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'TEST', CustomerInvoiceStaging."Test Code (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'TRANSACTTYPE', CustomerInvoiceStaging."Transact Type (Dimension)");
                        AssignDimensionSalesLine(SalesLine, 'VESSEL', CustomerInvoiceStaging."Vessel (Dimension)");
                        //<<PTC001

                        //SalesLine.VALIDATE(Amount, CustomerInvoiceStaging.Amount); SSLT

                        //SGB005
                        //SalesLine.VALIDATE("Shortcut Dimension 1 Code", CustomerInvoiceStaging."Country Code"); //PTC001
                        //SGB005

                        SalesLine.SKU := CustomerInvoiceStaging.SKU;
                        OnBeforeModifySalesLine_CreateSalesInvoices(CustomerInvoiceStaging, SalesLine);
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


        //COMMIT;

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

    procedure CheckSalesInvoices(ShowMessage: Boolean)
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
        TotalLine: Integer;
        ErrorLine: Integer;
        HandleNoValidation: Boolean;
        GLAcc: Record "G/L Account";
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
        OnBeforeModifyAllError_CheckSalesInvoices(CustomerInvoiceStaging);
        CustomerInvoiceStaging.MODIFYALL("Error Message", '');
        TotalLine := CustomerInvoiceStaging.COUNT;
        ErrorLine := 0;


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

                OnBeforeValidateNo_CheckSalesInvoices(CustomerInvoiceStaging, HandleNoValidation);

                Case CustomerInvoiceStaging.Type OF
                    CustomerInvoiceStaging.Type::" ":
                        Begin
                            CustomerInvoiceStaging."Error Message" := 'Type must not be blank.';

                            CustomerInvoiceStaging."Error 2" := TRUE;
                        End;
                    CustomerInvoiceStaging.Type::"Item":
                        BEgin
                            if not HandleNoValidation then begin
                                Item.SETRANGE("Integration Item", UPPERCASE(CustomerInvoiceStaging."Item No."));
                                if not ToCreateItem then begin
                                    IF NOT Item.FINDFIRST THEN BEGIN
                                        CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, 'Item', CustomerInvoiceStaging."Item No.");
                                        CustomerInvoiceStaging."Error 2" := TRUE;
                                    END;
                                end;

                                IF CustomerInvoiceStaging."Base Unit of Measure" = '' THEN BEGIN
                                    CustomerInvoiceStaging."Error Message" := STRSUBSTNO('%1 must have a value.', CustomerInvoiceStaging.FieldCaption("Base Unit of Measure"));
                                    CustomerInvoiceStaging."Error 2" := TRUE;
                                END;

                                IF CustomerInvoiceStaging."Gen. Product Posting Group" = '' THEN BEGIN
                                    CustomerInvoiceStaging."Error Message" := STRSUBSTNO('%1 must have a value.', CustomerInvoiceStaging.FieldCaption("Gen. Product Posting Group"));
                                    CustomerInvoiceStaging."Error 2" := TRUE;
                                END;

                                if Item.FindFirst() then;

                                if Item.Type = Item.Type::Inventory then
                                    IF CustomerInvoiceStaging."Inventory Posting Group" = '' THEN BEGIN
                                        CustomerInvoiceStaging."Error Message" := STRSUBSTNO('%1 must have a value.', CustomerInvoiceStaging.FieldCaption("Inventory Posting Group"));
                                        CustomerInvoiceStaging."Error 2" := TRUE;
                                    END;
                            end;
                        End;
                    CustomerInvoiceStaging.Type::"G/L Account":
                        begin
                            IF NOT GLAcc.GET(CustomerInvoiceStaging."Item No.") THEN BEGIN
                                CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, 'G/L Account', CustomerInvoiceStaging."Item No.");
                                CustomerInvoiceStaging."Error 2" := TRUE;
                            END;
                        end;
                END;

                IF NOT ConfigTemplateHeader.GET(CustomerInvoiceStaging."Integration Currency code") THEN BEGIN
                    CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50004, CustomerInvoiceStaging."Integration Currency code");
                    CustomerInvoiceStaging."Error 3" := TRUE;
                END;

                IF NOT CustomerInvoiceStaging.Regenerated THEN BEGIN
                    ProcessedCustomerInvoiceStaging.SETRANGE(Processed, TRUE);
                    ProcessedCustomerInvoiceStaging.SETRANGE("Shipment Increment Id", CustomerInvoiceStaging."Shipment Increment Id");    // ProcessedCustomerInvoiceStaging.SETRANGE("Order Increment Id", CustomerInvoiceStaging."Order Increment Id");
                    IF ProcessedCustomerInvoiceStaging.FINDFIRST THEN BEGIN
                        CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50000, CustomerInvoiceStaging."Shipment Increment Id", ProcessedCustomerInvoiceStaging."Entry No.");  // CustomerInvoiceStaging."Error Message" := STRSUBSTNO(Text50000, CustomerInvoiceStaging."Order Increment Id", ProcessedCustomerInvoiceStaging."Entry No.");
                        CustomerInvoiceStaging."Error 4" := TRUE;
                    END;
                END;

                OnValidateError_CheckSalesInvoices(CustomerInvoiceStaging);

                CustomerInvoiceStaging.MODIFY;

                IF CustomerInvoiceStaging."Error Message" <> '' THEN BEGIN
                    TempSalesHeader."No." := CustomerInvoiceStaging."Shipment Increment Id";   // TempSalesHeader."No." := CustomerInvoiceStaging."Order Increment Id";

                    IF TempSalesHeader.INSERT THEN;

                    ErrorLine += 1;
                END;
            UNTIL CustomerInvoiceStaging.NEXT = 0;



        IF CustomerInvoiceStaging.FINDSET THEN
            REPEAT
                IF TempSalesHeader.GET(0, CustomerInvoiceStaging."Shipment Increment Id") THEN BEGIN   // IF TempSalesHeader.GET(0, CustomerInvoiceStaging."Order Increment Id") THEN BEGIN
                    CustomerInvoiceStaging."Has Error" := TRUE;
                    CustomerInvoiceStaging.MODIFY;
                END;
            UNTIL CustomerInvoiceStaging.NEXT = 0;


        COMMIT;

        IF ShowMessage THEN
            MESSAGE(Text50010, TotalLine, ErrorLine);

        // if ErrorLine <> 0 then
        //     Error('');
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
                            ;//
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
                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50012, CustomePaymentStaging."Customer Id");
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
        DocNo: Text;
        test2: Text;
        HandlePurchLineNoValidation: Boolean;
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
                DocNo := (VendorInvoiceStaging.Contract + '_' + Format(VendorInvoiceStaging."Receiving Date", 0, '<Closing><Month,2><Day,2><Year>'));
                IF DocNo <> PrevDocNo THEN BEGIN
                    TempPurchHeader."Document Type" := TempPurchHeader."Document Type"::Invoice;
                    TempPurchHeader."No." := DocNo;
                    TempPurchHeader."Posting Date" := VendorInvoiceStaging."Receiving Date";
                    TempPurchHeader."Document Date" := VendorInvoiceStaging."Date Received";
                    TempPurchHeader."Vendor Invoice No." := VendorInvoiceStaging.Contract;
                    TempPurchHeader."Buy-from Vendor No." := VendorInvoiceStaging."Seller Id";
                    TempPurchHeader."Currency Factor" := VendorInvoiceStaging."Exchange Rate";
                    IF VendorInvoiceStaging."Integration Currency code" <> GLSetup."LCY Code" THEN
                        TempPurchHeader."Currency Code" := VendorInvoiceStaging."Integration Currency code"
                    ELSE
                        TempPurchHeader."Currency Code" := '';


                    IF TempPurchHeader.INSERT THEN;

                    PrevDocNo := DocNo;
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
                PurchHeader."Vendor Invoice No." := TempPurchHeader."Vendor Invoice No.";

                PurchHeader."Created from Integration" := TRUE;
                PurchHeader.VALIDATE("Currency Code", TempPurchHeader."Currency Code");

                IF TempPurchHeader."Currency Factor" = 0 then
                    TempPurchHeader."Currency Factor" := 1;

                PurchHeader."Currency Factor" := 1 / TempPurchHeader."Currency Factor";

                PurchHeader.INSERT(TRUE);

                //PurchHeader.VALIDATE("Document Date", TempPurchHeader."Document Date");
                PurchHeader.VALIDATE("Document Date", TempPurchHeader."Posting Date");
                PurchHeader.Modify(TRUE);

                NextLineNo := 0;
                VendorInvoiceStaging.SETRANGE(Contract, TempPurchHeader."Vendor Invoice No.");
                VendorInvoiceStaging.SETRANGE("Receiving Date", TempPurchHeader."Posting Date");
                IF VendorInvoiceStaging.FINDSET THEN
                    REPEAT
                        PurchLine.INIT;
                        PurchLine."Document Type" := PurchHeader."Document Type";
                        PurchLine."Document No." := PurchHeader."No.";
                        NextLineNo += 10000;
                        PurchLine."Line No." := NextLineNo;

                        PurchLine.INSERT(TRUE);

                        OnBeforeValidatePurchaseLineNo_CreatePurchInvoices(VendorInvoiceStaging, PurchLine, HandlePurchLineNoValidation);

                        if not HandlePurchLineNoValidation then begin
                            Item.SETRANGE("Integration Item", UPPERCASE(VendorInvoiceStaging."Item No."));
                            if Item.IsEmpty then
                                CreateItem(UPPERCASE(VendorInvoiceStaging."Item No."), VendorInvoiceStaging.Description, VendorInvoiceStaging."Base Unit of Measure", VendorInvoiceStaging."Gen. Product Posting Group", VendorInvoiceStaging."Inventory Posting Group");
                            Item.FINDFIRST;

                            PurchLine.VALIDATE(Type, PurchLine.Type::Item);
                            PurchLine.VALIDATE("No.", Item."No.");
                        end;


                        //SGB006
                        PurchLine.Description := VendorInvoiceStaging.Description;
                        //SGB006

                        PurchLine.VALIDATE(Quantity, VendorInvoiceStaging.Quantity);
                        /*PurchLine."Line Amount" := ROUND(VendorInvoiceStaging.SubTotal, 0.01); Old Code
                        PurchLine."Direct Unit Cost" := ROUND(VendorInvoiceStaging.SubTotal / VendorInvoiceStaging.Quantity, 0.01);*/
                        PurchLine.validate("Direct Unit Cost", VendorInvoiceStaging.Cost); //New SSLT Code
                        PurchLine.Validate("Integration Receiving ID", VendorInvoiceStaging."Receiving Id");

                        PurchLine.SKU := VendorInvoiceStaging.SKU;
                        OnBeforeModifyPurchaseLine_CreatePurchInvoices(VendorInvoiceStaging, PurchLine);
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


        //COMMIT;
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
        HandleNoValidation: Boolean;
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
        OnBeforeModifyAllError_CheckPurchInvoices(VendorInvoiceStaging);
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

                OnBeforeValidateNo_CheckPurchInvoices(VendorInvoiceStaging, HandleNoValidation);

                if not HandleNoValidation then begin
                    Item.SETRANGE("Integration Item", UPPERCASE(VendorInvoiceStaging."Item No."));
                    if not ToCreateItem then
                        IF NOT Item.FINDFIRST THEN BEGIN
                            VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50001, Item.TABLECAPTION, VendorInvoiceStaging."Item No.");
                            VendorInvoiceStaging."Error 2" := TRUE;
                        END;
                end;

                IF VendorInvoiceStaging."Base Unit of Measure" = '' THEN BEGIN
                    VendorInvoiceStaging."Error Message" := STRSUBSTNO('%1 must have a value.', VendorInvoiceStaging.FieldCaption("Base Unit of Measure"));
                    VendorInvoiceStaging."Error 2" := TRUE;
                END;

                IF VendorInvoiceStaging."Gen. Product Posting Group" = '' THEN BEGIN
                    VendorInvoiceStaging."Error Message" := STRSUBSTNO('%1 must have a value.', VendorInvoiceStaging.FieldCaption("Gen. Product Posting Group"));
                    VendorInvoiceStaging."Error 2" := TRUE;
                END;

                if Item.FindFirst() then;

                if Item.Type = Item.Type::Inventory then
                    IF VendorInvoiceStaging."Inventory Posting Group" = '' THEN BEGIN
                        VendorInvoiceStaging."Error Message" := STRSUBSTNO('%1 must have a value.', VendorInvoiceStaging.FieldCaption("Inventory Posting Group"));
                        VendorInvoiceStaging."Error 2" := TRUE;
                    END;

                //IF NOT ConfigTemplateHeader.GET("Integration Currency code") THEN BEGIN
                //  "Error Message" := STRSUBSTNO(Text50004,"Integration Currency code");
                //  "Error 3" := TRUE;
                //END;

                IF NOT VendorInvoiceStaging.Regenerated THEN BEGIN
                    ProcessedVendorInvoiceStaging.SETRANGE(Processed, TRUE);
                    ProcessedVendorInvoiceStaging.SETRANGE("Seller Id", VendorInvoiceStaging."Seller Id");
                    //ProcessedVendorInvoiceStaging.SETRANGE("Receiving Id", VendorInvoiceStaging."Receiving Id");
                    ProcessedVendorInvoiceStaging.SETRANGE(Contract, VendorInvoiceStaging.Contract);
                    ProcessedVendorInvoiceStaging.SETRANGE("Receiving Date", VendorInvoiceStaging."Receiving Date");


                    IF ProcessedVendorInvoiceStaging.FINDFIRST THEN BEGIN
                        //VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50000, VendorInvoiceStaging."Receiving Id", ProcessedVendorInvoiceStaging."Entry No.");
                        VendorInvoiceStaging."Error Message" := STRSUBSTNO(Text50000, VendorInvoiceStaging.Contract + '_' + Format(VendorInvoiceStaging."Receiving Date", 0, '<Closing><Month,2><Day,2><Year>'), ProcessedVendorInvoiceStaging."Entry No.");
                        VendorInvoiceStaging."Error 4" := TRUE;
                    END;
                END;

                OnValidateError_CheckPurchInvoices(VendorInvoiceStaging);

                if VendorInvoiceStaging."Purchase From" = 'US' then
                    if VendorInvoiceStaging."Integration Currency code" = 'CAD' then begin
                        VendorInvoiceStaging."Error 5" := true;
                        VendorInvoiceStaging."Error Message" := 'Check Magento Order';
                    end;

                VendorInvoiceStaging.MODIFY;

                IF VendorInvoiceStaging."Error Message" <> '' THEN BEGIN
                    //TempPurchHeader."No." := VendorInvoiceStaging."Receiving Id";
                    TempPurchHeader."No." := VendorInvoiceStaging.Contract + '_' + Format(VendorInvoiceStaging."Receiving Date", 0, '<Closing><Month,2><Day,2><Year>');
                    TempPurchHeader."Buy-from Vendor No." := VendorInvoiceStaging."Seller Id";

                    IF TempPurchHeader.INSERT THEN;

                    ErrorLine += 1;
                END;
            UNTIL VendorInvoiceStaging.NEXT = 0;



        IF VendorInvoiceStaging.FINDSET THEN
            REPEAT
                //TempPurchHeader.SETRANGE("No.", VendorInvoiceStaging."Receiving Id");
                TempPurchHeader.SETRANGE("No.", VendorInvoiceStaging.Contract + '_' + Format(VendorInvoiceStaging."Receiving Date", 0, '<Closing><Month,2><Day,2><Year>'));
                TempPurchHeader.SETRANGE("Buy-from Vendor No.", VendorInvoiceStaging."Seller Id");
                IF TempPurchHeader.FINDFIRST THEN BEGIN
                    VendorInvoiceStaging."Has Error" := TRUE;
                    VendorInvoiceStaging.MODIFY;
                END;
            UNTIL VendorInvoiceStaging.NEXT = 0;


        COMMIT;

        IF ShowMessage THEN
            MESSAGE(Text50010, TotalLine, ErrorLine);

        // if ErrorLine <> 0 then
        //     Error('');

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
                IF LocalPurchInvoiceStaging."Receiving Id" <> PrevDocNo THEN BEGIN
                    TempPurchHeader."Document Type" := TempPurchHeader."Document Type"::Invoice;
                    TempPurchHeader."No." := LocalPurchInvoiceStaging."Receiving Id";
                    TempPurchHeader."Buy-from Vendor No." := LocalPurchInvoiceStaging."Seller Id";
                    TempPurchHeader."Currency Factor" := LocalPurchInvoiceStaging."Exchange Rate";
                    TempPurchHeader."Posting Date" := LocalPurchInvoiceStaging."Receiving Date";
                    TempPurchHeader."Document Date" := LocalPurchInvoiceStaging."Date Received";
                    TempPurchHeader."Vendor Invoice No." := LocalPurchInvoiceStaging.Contract;
                    IF LocalPurchInvoiceStaging."Integration Currency code" <> GLSetup."LCY Code" THEN
                        TempPurchHeader."Currency Code" := LocalPurchInvoiceStaging."Integration Currency code"
                    ELSE
                        TempPurchHeader."Currency Code" := '';

                    IF TempPurchHeader.INSERT THEN;

                    PrevDocNo := LocalPurchInvoiceStaging."Receiving Id";
                END;
            UNTIL LocalPurchInvoiceStaging.NEXT = 0;



        TempPurchHeader.RESET;
        IF TempPurchHeader.FINDSET THEN
            REPEAT

                PurchInvoiceStaging.INIT;
                PurchInvoiceStaging."Receiving Id" := TempPurchHeader."No.";
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
        ProcessedPurchInvoiceStaging.SETRANGE("Receiving Id", LocalPurchInvoiceStaging."Receiving Id");
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

    procedure CheckOrder()
    begin
        CheckSalesOrder();
    end;

    procedure CheckSalesOrder()
    var
        CustomerOrderStaging: Record "Customer and Order Staging";
        ProcessedCustomerOrderStaging: Record "Customer and Order Staging";
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
        SalesHeader2: Record "Sales Header";
        SalesLine2: Record "Sales Line";
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

        CustomerOrderStaging.RESET;

        CustomerOrderStaging.SETRANGE(Processed, FALSE);
        CustomerOrderStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");


        CustomerOrderStaging.MODIFYALL("Has Error", FALSE);
        CustomerOrderStaging.MODIFYALL("Error 1", FALSE);
        CustomerOrderStaging.MODIFYALL("Error 2", FALSE);
        CustomerOrderStaging.MODIFYALL("Error 3", FALSE);
        CustomerOrderStaging.MODIFYALL("Error 4", FALSE);
        CustomerOrderStaging.MODIFYALL("Error Message", '');


        IF CustomerOrderStaging.FINDSET THEN
            REPEAT
                CustomerID := CustomerOrderStaging."Customer Id";

                IF NOT Customer.GET(CustomerID) THEN BEGIN
                    CustomerOrderStaging."Error Message" := STRSUBSTNO(Text50001, Customer.TABLECAPTION, CustomerOrderStaging."Customer Id");
                    CustomerOrderStaging."Error 1" := TRUE;
                END ELSE BEGIN
                    IF Customer."Customer Posting Group" = '' THEN BEGIN
                        CustomerOrderStaging."Error Message" := STRSUBSTNO(Text50002, Customer.TABLECAPTION, CustomerID);
                        CustomerOrderStaging."Error 1" := TRUE;
                    END;
                END;

                Item.SETRANGE("Integration Item", UPPERCASE(CustomerOrderStaging."Item No."));
                IF NOT Item.FINDFIRST THEN BEGIN
                    CustomerOrderStaging."Error Message" := STRSUBSTNO(Text50001, 'Item', CustomerOrderStaging."Item No.");
                    CustomerOrderStaging."Error 2" := TRUE;
                END;

                IF NOT ConfigTemplateHeader.GET(CustomerOrderStaging."Integration Currency code") THEN BEGIN
                    CustomerOrderStaging."Error Message" := STRSUBSTNO(Text50004, CustomerOrderStaging."Integration Currency code");
                    CustomerOrderStaging."Error 3" := TRUE;
                END;

                if not CustomerOrderStaging.Regenerated then begin
                    ProcessedCustomerOrderStaging.SETRANGE(Processed, TRUE);
                    ProcessedCustomerOrderStaging.SETRANGE("Order Increment Id", CustomerOrderStaging."Order Increment Id");
                    ProcessedCustomerOrderStaging.SetRange("Shipment Id", CustomerOrderStaging."Shipment Id");
                    if ProcessedCustomerOrderStaging.FINDFIRST then begin
                        CustomerOrderStaging."Error Message" := STRSUBSTNO(Text50014, CustomerOrderStaging."Order Increment Id", ProcessedCustomerOrderStaging."Entry No.");
                        CustomerOrderStaging."Error 4" := TRUE;
                    end;
                end;

                if not CustomerOrderStaging.Regenerated then begin
                    ProcessedCustomerOrderStaging.SETRANGE(Processed, TRUE);
                    ProcessedCustomerOrderStaging.SETRANGE("Order Increment Id", CustomerOrderStaging."Order Increment Id");
                    if ProcessedCustomerOrderStaging.FINDFIRST then begin
                        if SalesHeader2.Get(SalesHeader2."Document Type"::Order, ProcessedCustomerOrderStaging."Order Increment Id") then begin
                            SalesLine2.Reset();
                            SalesLine2.SetRange("Document Type", SalesHeader2."Document Type");
                            SalesLine2.SetRange("Document No.", SalesHeader2."No.");
                            SalesLine2.SetRange("No.", Item."No.");
                            if SalesLine2.FindSet() then begin
                                if SalesLine2.Quantity <> CustomerOrderStaging.Quantity then begin
                                    CustomerOrderStaging."Error Message" := STRSUBSTNO(Text50016, CustomerOrderStaging."Order Increment Id", CustomerOrderStaging."Item No.", Item."No.");
                                    CustomerOrderStaging."Error 4" := TRUE;
                                end;
                            end;
                        end;
                    end;
                end;

                CustomerOrderStaging.MODIFY;

                IF CustomerOrderStaging."Error Message" <> '' THEN BEGIN
                    TempSalesHeader."No." := CustomerOrderStaging."Order Increment Id";

                    IF TempSalesHeader.INSERT THEN;
                END;
            UNTIL CustomerOrderStaging.NEXT = 0;

        IF CustomerOrderStaging.FINDSET THEN
            REPEAT
                IF TempSalesHeader.GET(0, CustomerOrderStaging."Order Increment Id") THEN BEGIN
                    CustomerOrderStaging."Has Error" := TRUE;
                    CustomerOrderStaging.MODIFY;
                END;
            UNTIL CustomerOrderStaging.NEXT = 0;

        COMMIT;
    end;

    procedure SalesOrderProcess()
    begin
        CreateCustomersOrder();
        CheckSalesOrder();
        CreateSalesOrder();
    end;

    procedure CreateCustomersOrder()
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
        CustomeOrderStaging: Record "Customer and Order Staging";
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;

        TempCustomer.RESET;
        TempCustomer.DELETEALL;


        CustomeOrderStaging.SETCURRENTKEY("Shipped From", Processed);
        CustomeOrderStaging.SETRANGE(Processed, FALSE);
        CustomeOrderStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");

        IF CustomeOrderStaging.FINDSET THEN
            REPEAT

                CustomerID := CustomeOrderStaging."Customer Id";
                TemplateCode := CustomeOrderStaging."Integration Currency code";

                IF NOT TempCustomer.GET(CustomerID) THEN BEGIN
                    IF Customer.GET(CustomerID) THEN BEGIN
                        Customer.VALIDATE(Name, CustomeOrderStaging."Customer Name");
                        Customer.MODIFY;
                    END ELSE BEGIN
                        Customer.INIT;
                        Customer."No." := CustomerID;
                        Customer.VALIDATE(Name, CustomeOrderStaging."Customer Name");
                        Customer.INSERT(TRUE);

                        TempCustomer := Customer;
                        TempCustomer.INSERT;

                        RecRef.GETTABLE(Customer);
                        ConfigTemplateHeader.GET(TemplateCode);
                        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                    END;
                END ELSE BEGIN
                    Customer.GET(CustomerID)
                END;

            UNTIL CustomeOrderStaging.NEXT = 0;

        COMMIT;
    end;

    procedure CreateSalesOrder()
    var
        CustomerOrderStaging: Record "Customer and Order Staging";
        CustomerOrderStaging2: Record "Customer and Order Staging";
        TempSalesHeader: Record "Sales Header" temporary;
        TempCustomerOrderStaging: Record "Customer and Order Staging" temporary;
        IntegrationSetup: Record "Integration Setup";
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        Item: Record Item;
        ConfigTemplateHeader: Record "Config. Template Header";
        CompanyInfo: Record "Company Information";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesHeader2: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        SalesPost: Codeunit "Sales-Post";
        CustomerID: Code[20];
        RecRef: RecordRef;
        TemplateCode: Code[20];
        PrevDocNo: Code[20];
        NextLineNo: Integer;
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        IsStatusOpen: Boolean;
        withError: Boolean;
        TotalSalesLine: Integer;
    begin
        CompanyInfo.GET;
        CompanyInfo.TESTFIELD("Shipped From");

        IntegrationSetup.GET;

        IF NOT CONFIRM(Text50015, FALSE) THEN BEGIN
            MESSAGE(Text50006);
            EXIT
        END;

        TempSalesHeader.RESET;
        TempSalesHeader.DELETEALL;

        TempCustomerOrderStaging.RESET;
        TempCustomerOrderStaging.DELETEALL;

        PrevDocNo := '';

        CustomerOrderStaging.SETCURRENTKEY("Shipped From", Processed);

        CustomerOrderStaging.SETRANGE(Processed, FALSE);
        CustomerOrderStaging.SETRANGE("Shipped From", CompanyInfo."Shipped From");
        CustomerOrderStaging.SETRANGE("Has Error", FALSE);
        CustomerOrderStaging2.Copy(CustomerOrderStaging);
        IF CustomerOrderStaging.FINDSET THEN
            REPEAT
                IF CustomerOrderStaging."Order Increment Id" <> PrevDocNo THEN BEGIN
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Order;
                    TempSalesHeader."No." := CustomerOrderStaging."Order Increment Id";
                    TempSalesHeader."Sell-to Customer No." := CustomerOrderStaging."Customer Id";
                    TempSalesHeader."Currency Factor" := CustomerOrderStaging."Exchange Rate";
                    TempSalesHeader."Posting Date" := CustomerOrderStaging."Order Date";
                    //TempSalesHeader."Shortcut Dimension 1 Code" := CustomerOrderStaging."Country Code";//PTC001
                    TempSalesHeader."External Document No." := CustomerOrderStaging."Order Increment Id";
                    /*TempSalesHeader.LTH := CustomerOrderStaging.LTH;
                    TempSalesHeader.LTHSHIP := CustomerOrderStaging.LTHSHIP;*///removal SSLT - moved to lines

                    IF TempSalesHeader.INSERT THEN;

                    PrevDocNo := CustomerOrderStaging."Order Increment Id";
                END;
            UNTIL CustomerOrderStaging.NEXT = 0;


        TempSalesHeader.RESET;
        IF TempSalesHeader.FINDSET THEN
            REPEAT
                if SalesHeader2.Get(SalesHeader2."Document Type"::Order, TempSalesHeader."No.") then begin //Check if SO already existing
                    IsStatusOpen := (SalesHeader2.Status = SalesHeader2.Status::Open);

                    if not IsStatusOpen then begin //released means already posted - so clear out qty fields
                        ReleaseSalesDoc.PerformManualReopen(SalesHeader2);
                        SalesLine2.Reset();
                        SalesLine2.SetRange("Document Type", SalesHeader2."Document Type");
                        SalesLine2.SetRange("Document No.", SalesHeader2."No.");
                        if SalesLine2.FindSet() then begin
                            SalesLine2.ModifyAll("Qty. to Invoice", 0);
                            SalesLine2.ModifyAll("Qty. to Invoice (Base)", 0);
                            SalesLine2.ModifyAll("Qty. to Ship", 0);
                            SalesLine2.ModifyAll("Qty. to Ship (Base)", 0);
                        end;
                    end;

                    SalesLine2.Reset();
                    SalesLine2.SetRange("Document Type", SalesHeader2."Document Type");
                    SalesLine2.SetRange("Document No.", SalesHeader2."No.");
                    if SalesLine2.FindLast() then
                        NextLineNo := SalesLine2."Line No."
                    else
                        NextLineNo := 0;

                    CustomerOrderStaging.SETRANGE("Order Increment Id", TempSalesHeader."No.");
                    IF CustomerOrderStaging.FINDSET THEN
                        REPEAT
                            withError := false;
                            Item.SETRANGE("Integration Item", UPPERCASE(CustomerOrderStaging."Item No."));
                            Item.FINDFIRST;

                            SalesLine2.Reset();
                            SalesLine2.SetRange("Document Type", SalesHeader2."Document Type");
                            SalesLine2.SetRange("Document No.", SalesHeader2."No.");
                            SalesLine2.SetRange("No.", Item."No.");
                            if SalesLine2.FindSet() then begin //IF sales lines is existing
                                if IsStatusOpen then begin
                                    //For Order Types not equal to 1,1
                                    if ((not CustomerOrderStaging.LTH) and (not CustomerOrderStaging.LTHSHIP)) then
                                        if (SalesLine2."Shipment Id" <> CustomerOrderStaging."Shipment Id") then begin
                                            SalesLine2.validate("Qty. to Ship", (SalesLine2."Qty. to Ship" + CustomerOrderStaging."Quantity Shipped"));
                                            SalesLine2.validate("Shipment Id", CustomerOrderStaging."Shipment Id"); //SSLT
                                            SalesLine2.Validate("Shipment Date", CustomerOrderStaging."Shipment Date"); //SSLT
                                        end else begin
                                            CustomerOrderStaging."Error 1" := true;
                                            CustomerOrderStaging."Error Message" := StrSubstNo('Shipment ID already exist in Order %1, Line No. %2, Item %3', SalesLine2."Document No.", SalesLine2."Line No.", SalesLine2."No.");
                                            CustomerOrderStaging."Has Error" := true;
                                            CustomerOrderStaging.Modify();
                                            withError := true;
                                        end;

                                    //For Order = 1,1 (Partial and full should already have a posted SO)
                                    if (CustomerOrderStaging.LTH) and (CustomerOrderStaging.LTHSHIP) then begin
                                        if isSOPosted(CustomerOrderStaging."Order Increment Id", CustomerOrderStaging."Quantity Shipped") then begin
                                            if (SalesLine2."Shipment Id" <> CustomerOrderStaging."Shipment Id") then begin
                                                SalesLine2.validate("Qty. to Ship", (SalesLine2."Qty. to Ship" + CustomerOrderStaging."Quantity Shipped"));
                                                SalesLine2.validate("Shipment Id", CustomerOrderStaging."Shipment Id"); //SSLT
                                                SalesLine2.Validate("Shipment Date", CustomerOrderStaging."Shipment Date"); //SSLT
                                                PostNegativeAdjustmentLTH(TempSalesHeader, CustomerOrderStaging);
                                            end else begin
                                                CustomerOrderStaging."Error 1" := true;
                                                CustomerOrderStaging."Error Message" := StrSubstNo('Shipment ID already exist in Order %1, Line No. %2, Item %3', SalesLine2."Document No.", SalesLine2."Line No.", SalesLine2."No.");
                                                CustomerOrderStaging."Has Error" := true;
                                                CustomerOrderStaging.Modify();
                                                withError := true;
                                            end;
                                        end else begin //For 1,1 Orders there should be a SO Posted already before negative adj can happen, if partial then SO should be posted as well but should not exceed the qty shipped
                                            CustomerOrderStaging."Error 1" := true;
                                            CustomerOrderStaging."Error Message" := isSOPostedErrorMsg;
                                            CustomerOrderStaging."Has Error" := true;
                                            CustomerOrderStaging.Modify();
                                            withError := true;
                                        end;

                                    end;

                                end else begin //status still not open 
                                    if (CustomerOrderStaging.LTH) and (CustomerOrderStaging.LTHSHIP) then begin
                                        if isSOPosted(CustomerOrderStaging."Order Increment Id", CustomerOrderStaging."Quantity Shipped") then begin
                                            if (SalesLine2."Shipment Id" <> CustomerOrderStaging."Shipment Id") then begin
                                                SalesLine2.validate("Qty. to Ship", (SalesLine2."Qty. to Ship" + CustomerOrderStaging."Quantity Shipped"));
                                                SalesLine2.validate("Shipment Id", CustomerOrderStaging."Shipment Id"); //SSLT
                                                SalesLine2.Validate("Shipment Date", CustomerOrderStaging."Shipment Date"); //SSLT
                                                PostNegativeAdjustmentLTH(TempSalesHeader, CustomerOrderStaging);
                                            end else begin
                                                CustomerOrderStaging."Error 1" := true;
                                                CustomerOrderStaging."Error Message" := StrSubstNo('Shipment ID already exist in Order %1, Line No. %2, Item %3', SalesLine2."Document No.", SalesLine2."Line No.", SalesLine2."No.");
                                                CustomerOrderStaging."Has Error" := true;
                                                CustomerOrderStaging.Modify();
                                                withError := true;
                                            end;
                                        end else begin //For 1,1 Orders there should be a SO Posted already before negative adj can happen, if partial then SO should be posted as well but should not exceed the qty shipped
                                            CustomerOrderStaging."Error 1" := true;
                                            CustomerOrderStaging."Error Message" := isSOPostedErrorMsg;
                                            CustomerOrderStaging."Has Error" := true;
                                            CustomerOrderStaging.Modify();
                                            withError := true;
                                        end;
                                    end else begin
                                        SalesLine2."Qty. to Invoice" := CustomerOrderStaging."Quantity Shipped";
                                        SalesLine2."Qty. to Invoice (Base)" := CustomerOrderStaging."Quantity Shipped";
                                        SalesLine2."Qty. to Ship" := CustomerOrderStaging."Quantity Shipped";
                                        SalesLine2."Qty. to Ship (Base)" := CustomerOrderStaging."Quantity Shipped";
                                        SalesLine2.validate("Shipment Id", CustomerOrderStaging."Shipment Id"); //SSLT
                                        SalesLine2.Validate("Shipment Date", CustomerOrderStaging."Shipment Date"); //SSLT
                                    end;
                                end;

                                SalesLine2.MODIFY;
                                if not withError then begin
                                    TempCustomerOrderStaging."Entry No." := CustomerOrderStaging."Entry No.";
                                    TempCustomerOrderStaging.INSERT;
                                end;
                            end else begin //If Sales Line not existing 

                                SalesLine2.INIT;
                                SalesLine2."Document Type" := SalesHeader2."Document Type";
                                SalesLine2."Document No." := SalesHeader2."No.";
                                NextLineNo += 10000;
                                SalesLine2."Line No." := NextLineNo;

                                SalesLine2.INSERT(TRUE);

                                SalesLine2.VALIDATE(Type, SalesLine2.Type::Item);
                                SalesLine2.VALIDATE("No.", Item."No.");
                                SalesLine2.VALIDATE(Quantity, CustomerOrderStaging.Quantity);
                                SalesLine2.VALIDATE("Unit Price", CustomerOrderStaging."Unit Price");
                                SalesLine2.VALIDATE("Qty. to Invoice", CustomerOrderStaging."Quantity Shipped");
                                SalesLine2.VALIDATE("Qty. to Invoice (Base)", CustomerOrderStaging."Quantity Shipped");
                                SalesLine2.VALIDATE("Qty. to Ship", CustomerOrderStaging."Quantity Shipped");
                                SalesLine2.VALIDATE("Qty. to Ship (Base)", CustomerOrderStaging."Quantity Shipped");
                                //SalesLine2.VALIDATE("Shortcut Dimension 1 Code", CustomerOrderStaging."Country Code"); //PTC001
                                SalesLine2.Validate(LTH, CustomerOrderStaging.LTH); //SSLT
                                SalesLine2.Validate(LTHSHIP, CustomerOrderStaging.LTHSHIP); //SSLT
                                SalesLine2.validate("Shipment Id", CustomerOrderStaging."Shipment Id"); //SSLT
                                SalesLine2.Validate("Shipment Date", CustomerOrderStaging."Shipment Date"); //SSLT
                                SalesLine2.MODIFY;

                                TempCustomerOrderStaging."Entry No." := CustomerOrderStaging."Entry No.";
                                TempCustomerOrderStaging.INSERT;
                            end;

                        UNTIL CustomerOrderStaging.NEXT = 0;

                end else begin //SO Does not exist 
                    CustomerID := TempSalesHeader."Sell-to Customer No.";

                    SalesHeader.INIT;
                    SalesHeader.SetHideValidationDialog(true);
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                    SalesHeader.VALIDATE("No.", TempSalesHeader."No.");
                    SalesHeader.VALIDATE("Sell-to Customer No.", CustomerID);
                    SalesHeader.VALIDATE("Posting Date", TempSalesHeader."Posting Date");
                    SalesHeader."Currency Factor" := 1 / TempSalesHeader."Currency Factor";
                    // SalesHeader."Posting No." := SalesHeader."No.";  //SS.AM - Set Default Posting No Series
                    SalesHeader."Created from Integration" := TRUE;
                    SalesHeader."External Document No." := TempSalesHeader."External Document No.";
                    //SalesHeader.LTH := TempSalesHeader.LTH; //SSLT removal
                    //SalesHeader.LTHSHIP := TempSalesHeader.LTHSHIP; //SSLT removal

                    SalesHeader.INSERT(TRUE);

                    SalesHeader.GET(SalesHeader."Document Type"::Order, TempSalesHeader."No.");

                    //SalesHeader.VALIDATE("Shortcut Dimension 1 Code", TempSalesHeader."Shortcut Dimension 1 Code"); //PTC001
                    SalesHeader.MODIFY;

                    NextLineNo := 0;
                    TotalSalesLine := 0;
                    CustomerOrderStaging.SETRANGE("Order Increment Id", TempSalesHeader."No.");
                    IF CustomerOrderStaging.FINDSET THEN BEGIN
                        REPEAT
                            //Post negative adjustments sslt
                            if (CustomerOrderStaging.LTH and CustomerOrderStaging.LTHSHIP) then begin
                                //Check validation if there are any posted entries
                                if isSOPosted(CustomerOrderStaging."Order Increment Id", CustomerOrderStaging."Quantity Shipped") then begin
                                    PostNegativeAdjustmentLTH(TempSalesHeader, CustomerOrderStaging);
                                    TempCustomerOrderStaging."Entry No." := CustomerOrderStaging."Entry No.";
                                    TempCustomerOrderStaging.INSERT;
                                end else begin
                                    CustomerOrderStaging."Error 1" := true;
                                    CustomerOrderStaging."Error Message" := isSOPostedErrorMsg;
                                    CustomerOrderStaging."Has Error" := true;
                                    CustomerOrderStaging.Modify();
                                    withError := true;
                                end;
                            end else begin
                                SalesLine.INIT;
                                SalesLine."Document Type" := SalesHeader."Document Type";
                                SalesLine."Document No." := SalesHeader."No.";
                                NextLineNo += 10000;
                                SalesLine."Line No." := NextLineNo;

                                SalesLine.INSERT(TRUE);
                                TotalSalesLine += 1;

                                Item.SETRANGE("Integration Item", UPPERCASE(CustomerOrderStaging."Item No."));
                                Item.FINDFIRST;

                                SalesLine.VALIDATE(Type, SalesLine.Type::Item);
                                SalesLine.VALIDATE("No.", Item."No.");
                                SalesLine.VALIDATE(Quantity, CustomerOrderStaging.Quantity);
                                SalesLine.VALIDATE("Unit Price", CustomerOrderStaging."Unit Price");
                                SalesLine.VALIDATE("Qty. to Invoice", CustomerOrderStaging."Quantity Shipped");
                                SalesLine.VALIDATE("Qty. to Invoice (Base)", CustomerOrderStaging."Quantity Shipped");
                                SalesLine.VALIDATE("Qty. to Ship", CustomerOrderStaging."Quantity Shipped");
                                SalesLine.VALIDATE("Qty. to Ship (Base)", CustomerOrderStaging."Quantity Shipped");
                                SalesLine.VALIDATE("Shortcut Dimension 1 Code", CustomerOrderStaging."Country Code");
                                SalesLine.Validate(LTH, CustomerOrderStaging.LTH); //SSLT
                                SalesLine.Validate(LTHSHIP, CustomerOrderStaging.LTHSHIP); //SSLT
                                SalesLine.validate("Shipment Id", CustomerOrderStaging."Shipment Id"); //SSLT
                                SalesLine.Validate("Shipment Date", CustomerOrderStaging."Shipment Date"); //SSLT
                                SalesLine.MODIFY;

                                TempCustomerOrderStaging."Entry No." := CustomerOrderStaging."Entry No.";
                                TempCustomerOrderStaging.INSERT;
                            end;
                        UNTIL CustomerOrderStaging.NEXT = 0;
                    END;
                    if TotalSalesLine = 0 then  //For 1,1 Order - if No Sales Line then delete Sales Header
                        if SalesHeader.GET(SalesHeader."Document Type"::Order, TempSalesHeader."No.") then
                            SalesHeader.Delete();
                end;

            UNTIL TempSalesHeader.NEXT = 0;

        IF TempCustomerOrderStaging.FINDSET THEN
            REPEAT
                CustomerOrderStaging.GET(TempCustomerOrderStaging."Entry No.");
                CustomerOrderStaging.Processed := TRUE;
                CustomerOrderStaging."Date Processed" := CURRENTDATETIME;
                CustomerOrderStaging."Processed By" := USERID;
                CustomerOrderStaging.MODIFY;
            UNTIL TempCustomerOrderStaging.NEXT = 0;


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

    local procedure isSOPosted(OrderNo: Code[20]; QtyShipped: decimal): Boolean
    var
        SalesShipHdr: Record "Sales Shipment Header";
        SalesShipLine: Record "Sales Shipment Line";
        ile: record "Item Ledger Entry";
        TotalShipped: Decimal;
        TotalNegAdj: Decimal;

    begin
        isSOPostedErrorMsg := '';
        clear(TotalShipped);
        Clear(ile);
        ile.SetRange("External Document No.", OrderNo);
        ile.SetRange("Entry Type", ile."Entry Type"::Sale);
        if ile.FindSet() then begin
            ile.CalcSums(Quantity);
            TotalShipped := ile.Quantity;
        end else begin
            //No Posted SO 
            isSOPostedErrorMsg := StrSubstNo('There is no existing Order posted for Order No. %1', OrderNo);
            exit(false);
        end;

        Clear(ile);
        ile.SetRange("External Document No.", OrderNo);
        ile.SetRange("Entry Type", ile."Entry Type"::"Negative Adjmt.");
        if ile.FindSet() then begin
            ile.CalcSums(Quantity);
            TotalNegAdj := ile.Quantity;
        end;

        if ABS(TotalShipped) >= QtyShipped then
            exit(true)
        else begin
            isSOPostedErrorMsg := StrSubstNo('Quantity must not exceed Quantity Shipped for Order No. %1 ', OrderNo);
            exit(false);
        end;

    end;

    local procedure PostNegativeAdjustmentLTH(SalesHeader: Record "Sales Header"; var CustandOrdStaging: Record "Customer and Order Staging")
    var
        ItemJnlPostLn: Codeunit "Item Jnl.-Post Line";
        ItemJnlLn: Record "Item Journal Line";
        IntegrationSetup: Record "Integration Setup";
        Item: Record Item;
        LastLineNo: Integer;
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        UnitCost: Decimal;
    begin
        ItemJnlLn.Reset();
        ItemJnlLn.SetRange("Journal Template Name", 'ITEM');
        ItemJnlLn.SetRange("Journal Batch Name", 'SO_INTEG');
        if ItemJnlLn.FindLast() then
            LastLineNo := ItemJnlLn."Line No."
        else
            LastLineNo := 0;

        CustandOrdStaging.SETRANGE("Order Increment Id", SalesHeader."No.");
        if CustandOrdStaging.FINDSET then begin
            repeat
                Item.Reset();
                Item.SETRANGE("Integration Item", UPPERCASE(CustandOrdStaging."Item No."));
                Item.FINDFIRST;

                if (Item.Type = Item.Type::Inventory) then begin
                    ItemJnlLn.Init();
                    ItemJnlLn."Journal Template Name" := 'ITEM';
                    ItemJnlLn."Journal Batch Name" := 'SO_INTEG';

                    //Get Unit Cost from Positive Adj. - Value Entry
                    Clear(ValueEntry);
                    ValueEntry.SetRange("Document No.", SalesHeader."No.");
                    ValueEntry.SetRange("Item No.", Item."No.");
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.");
                    if ValueEntry.FindFirst() then
                        UnitCost := ValueEntry."Cost per Unit";

                    LastLineNo := LastLineNo + 10000;
                    ItemJnlLn."Line No." := LastLineNo;

                    ItemJnlLn."Document No." := SalesHeader."No.";
                    ItemJnlLn.Validate("Entry Type", ItemJnlLn."Entry Type"::"Negative Adjmt.");
                    ItemJnlLn.Validate("Posting Date", SalesHeader."Posting Date");
                    ItemJnlLn.Validate("Item No.", Item."No.");
                    ItemJnlLn.Validate(Quantity, CustandOrdStaging."Quantity Shipped");
                    ItemJnlLn.Validate("Unit Amount", CustandOrdStaging."Unit Price");
                    ItemJnlLn.Validate("Unit Cost", UnitCost);
                    ItemJnlLn.Validate("External Document No.", SalesHeader."External Document No.");
                    ItemJnlLn.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
                    ItemJnlLn.Validate("Applies-to Entry", 0);

                    IntegrationSetup.Get();
                    ItemJnlLn.Validate("Gen. Prod. Posting Group", IntegrationSetup."Sales Gen. Prod Posting Group");
                    ItemJnlLn.Validate("Gen. Bus. Posting Group", '');

                    ItemJnlLn.Insert();
                    Clear(ItemJnlPostLn);
                    ItemJnlPostLn.Run(ItemJnlLn);

                end;
            until CustandOrdStaging.Next() = 0;
        end;
    end;

    procedure ReGenerateCustomerandOrderStaging(var LocalCustomerOrderStaging: Record "Customer and Order Staging")
    var
        CustomerOrderStaging: Record "Customer and Order Staging";
        ProcessedCustomerOrderStaging: Record "Customer and Order Staging";
        TempSalesHeader: Record "Sales Header" temporary;
        PrevDocNo: Code[20];
    begin
        TempSalesHeader.RESET;
        TempSalesHeader.DELETEALL;

        PrevDocNo := '';


        IF LocalCustomerOrderStaging.FINDSET THEN
            REPEAT
                IF LocalCustomerOrderStaging."Order Increment Id" <> PrevDocNo THEN BEGIN
                    TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Order;
                    TempSalesHeader."No." := LocalCustomerOrderStaging."Order Increment Id";
                    TempSalesHeader."Sell-to Customer No." := LocalCustomerOrderStaging."Customer Id";
                    TempSalesHeader."Currency Factor" := LocalCustomerOrderStaging."Exchange Rate";
                    TempSalesHeader."Posting Date" := LocalCustomerOrderStaging."Order Date";

                    IF TempSalesHeader.INSERT THEN;

                    PrevDocNo := LocalCustomerOrderStaging."Order Increment Id";
                END;
            UNTIL LocalCustomerOrderStaging.NEXT = 0;


        TempSalesHeader.RESET;
        IF TempSalesHeader.FINDSET THEN
            REPEAT
                CustomerOrderStaging.INIT;
                CustomerOrderStaging."Order Increment Id" := TempSalesHeader."No.";
                CustomerOrderStaging."Customer Id" := TempSalesHeader."Sell-to Customer No.";

                ReGenerateCustomerandOrder(CustomerOrderStaging)

            UNTIL TempSalesHeader.NEXT = 0;
    end;

    procedure ReGenerateCustomerandOrder(LocalCustomerOrderStaging: Record "Customer and Order Staging")
    var
        CustomerOrderStaging: Record "Customer and Order Staging";
        ProcessedCustomerOrderStaging: Record "Customer and Order Staging";
    begin
        ProcessedCustomerOrderStaging.RESET;
        ProcessedCustomerOrderStaging.SETRANGE(Processed, TRUE);
        ProcessedCustomerOrderStaging.SETRANGE("Order Increment Id", LocalCustomerOrderStaging."Order Increment Id");
        ProcessedCustomerOrderStaging.SETRANGE("Customer Id", LocalCustomerOrderStaging."Customer Id");
        IF ProcessedCustomerOrderStaging.FINDSET THEN
            REPEAT
                CustomerOrderStaging.INIT;

                CustomerOrderStaging := ProcessedCustomerOrderStaging;

                CustomerOrderStaging."Entry No." := 0;
                CustomerOrderStaging.Processed := FALSE;
                CustomerOrderStaging."Date Processed" := 0DT;
                CustomerOrderStaging."Processed By" := '';
                CustomerOrderStaging."Has Error" := FALSE;
                CustomerOrderStaging."Error 1" := FALSE;
                CustomerOrderStaging."Error 2" := FALSE;
                CustomerOrderStaging."Error 3" := FALSE;
                CustomerOrderStaging."Error 4" := FALSE;
                CustomerOrderStaging."Error Message" := '';
                CustomerOrderStaging.Regenerated := TRUE;
                CustomerOrderStaging."Regenerated from Entry No." := ProcessedCustomerOrderStaging."Entry No.";

                CustomerOrderStaging.INSERT(TRUE);
            UNTIL ProcessedCustomerOrderStaging.NEXT = 0;
    end;

    procedure CheckCashReceiptJnlV2()
    var
        CompanyInfo: Record "Company Information";
        IntegrationSetup: Record "Integration Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        CustomePaymentStaging: Record "Cust Cash Rcpt Staging v2";
        ProcessedCustomePaymentStaging: Record "Cust Cash Rcpt Staging v2";
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
                            ;//
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

                /*IF CustomePaymentStaging."Order Increment Id" <> '' THEN BEGIN
                    OldCustLedgEntry.RESET;
                    OldCustLedgEntry.SetCurrentKey("External Document No."); // JAP - Change to External Doc. No. - 07/29/2021
                    // OldCustLedgEntry.SETCURRENTKEY("Document No.");       // JAP - Comment - 07/29/2021
                    // OldCustLedgEntry.SETFILTER("Posting Date", '..%1',"Posting Date");

                    OldCustLedgEntry.SETRANGE("External Document No.", CustomePaymentStaging."Order Increment Id"); // JAP - Change to External Doc. No. - 07/29/2021
                    // OldCustLedgEntry.SETRANGE("Document No.", CustomePaymentStaging."Order Increment Id");       // JAP - Comment - 07/29/2021
                    OldCustLedgEntry.SETRANGE("Document Type", OldCustLedgEntry."Document Type"::Invoice);
                    OldCustLedgEntry.SETRANGE("Customer No.", CustomePaymentStaging."Customer Id");
                    OldCustLedgEntry.SETRANGE(Open, TRUE);

                    IF NOT OldCustLedgEntry.FINDFIRST THEN BEGIN
                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50012, CustomePaymentStaging."Customer Id");
                        CustomePaymentStaging."Error 4" := TRUE;
                    END
                END;*/ //SSLT 10-19-2021

                /*IF CustomePaymentStaging."Order Increment Id" <> '' THEN BEGIN
                    OldCustLedgEntry.RESET;
                    OldCustLedgEntry.SetCurrentKey("External Document No."); // JAP - Change to External Doc. No. - 07/29/2021
                    // OldCustLedgEntry.SETCURRENTKEY("Document No.");       // JAP - Comment - 07/29/2021
                    OldCustLedgEntry.SETFILTER("Posting Date", '..%1', CustomePaymentStaging."Posting Date");

                    OldCustLedgEntry.SETRANGE("External Document No.", CustomePaymentStaging."Order Increment Id"); // JAP - Change to External Doc. No. - 07/29/2021
                    // OldCustLedgEntry.SETRANGE("Document No.", CustomePaymentStaging."Order Increment Id");       // JAP - Comment - 07/29/2021
                    OldCustLedgEntry.SETRANGE("Document Type", OldCustLedgEntry."Document Type"::Invoice);
                    OldCustLedgEntry.SETRANGE("Customer No.", CustomePaymentStaging."Customer Id");
                    OldCustLedgEntry.SETRANGE(Open, TRUE);

                    IF NOT OldCustLedgEntry.FINDFIRST THEN BEGIN
                        CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50013);
                        CustomePaymentStaging."Error 4" := TRUE;
                    END
                END;*/ //SSLT 10-19-2021


                ProcessedCustomePaymentStaging.SETRANGE(Processed, TRUE);
                ProcessedCustomePaymentStaging.SETRANGE("Customer Id", "CustomerId");
                ProcessedCustomePaymentStaging.SETRANGE("Document No.", CustomePaymentStaging."Document No.");
                IF NOT ProcessedCustomePaymentStaging.ISEMPTY THEN BEGIN
                    CustomePaymentStaging."Error Message" := STRSUBSTNO(Text50007, CustomePaymentStaging."Document No.", CustomePaymentStaging."Entry No.");
                    CustomePaymentStaging."Error 4" := TRUE;
                END;


                IF CustomePaymentStaging."Error Message" = '' THEN
                    CustomePaymentStaging."Has Error" := FALSE
                ELSE
                    CustomePaymentStaging."Has Error" := TRUE;

                CustomePaymentStaging.MODIFY;

            UNTIL CustomePaymentStaging.NEXT = 0;



        //DialogWindow.CLOSE;

        //MESSAGE(Text50004,i,IntegrationSetup."Payroll Journal Batch");

    end;

    procedure CreateCashReceiptJnlV2()
    var
        CompanyInfo: Record "Company Information";
        IntegrationSetup: Record "Integration Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        CustomePaymentStaging: Record "Cust Cash Rcpt Staging v2";
        TempCustomePaymentStaging: Record "Cust Cash Rcpt Staging v2" temporary;
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

        if TempCLERemaining.IsTemporary then
            TempCLERemaining.DeleteAll();

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
                GenJnlLine.Validate("External Document No.", CustomePaymentStaging."Order Increment Id"); //SSLT
                GenJnlLine.VALIDATE("Account Type", GenJnlLine."Account Type"::Customer);
                GenJnlLine.VALIDATE("Account No.", CustomePaymentStaging."Customer Id");
                // GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice); // JAP - Comment - 07/29/2021
                // GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.", CustomePaymentStaging."Order Increment Id");  // JAP - Comment - 07/29/2021

                GenJnlLine.Description := COPYSTR(CustomePaymentStaging."Payment Type" + ' ' + GenJnlLine."Account No.", 1, 50);
                IF CustomePaymentStaging."Integration Currency Code" <> GLSetup."LCY Code" THEN BEGIN
                    GenJnlLine.VALIDATE("Currency Code", CustomePaymentStaging."Integration Currency Code");
                    GenJnlLine.VALIDATE("Currency Factor", ROUND(1 / CustomePaymentStaging."Exchange Rate", 0.00001));
                END;


                GenJnlLine.VALIDATE(Amount, -CustomePaymentStaging.Amount);
                GenJnlLine.VALIDATE("Applies-to Doc. No.", '');
                // GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice); // JAP - Comment - 07/29/2021
                // GenJnlLine.VALIDATE(GenJnlLine."Applies-to Doc. No.", CustomePaymentStaging."Order Increment Id");  // JAP - Comment - 07/29/2021

                PaymentTypeMapping.GET(UPPERCASE(CustomePaymentStaging."Payment Type"), CustomePaymentStaging."Integration Currency Code");
                CASE PaymentTypeMapping."NAV Type" OF
                    PaymentTypeMapping."NAV Type"::"G/L Account":
                        GenJnlLine.VALIDATE("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                    PaymentTypeMapping."NAV Type"::"Bank Account":
                        GenJnlLine.VALIDATE("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
                END;

                GenJnlLine.VALIDATE("Bal. Account No.", PaymentTypeMapping."NAV No.");
                GenJnlLine.MODIFY;

                //Check if already made payments and it has remaining application 
                TempCLERemaining.Reset();
                TempCLERemaining.SetRange("External Document No.", CustomePaymentStaging."Order Increment Id");
                if not TempCLERemaining.FindFirst() then
                    CashReceiptApplyAmount(CustomePaymentStaging."Order Increment Id", CustomePaymentStaging."Document No.", CustomePaymentStaging.Amount, CustomePaymentStaging."Posting Date"); // JAP - 07/29/2021

                if WithAppliedEntries then begin
                    GenJnlLine.Validate("Applies-to ID", GenJnlLine."Document No.");
                    GenJnlLine.MODIFY;
                end;

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

    local procedure CashReceiptApplyAmount(pOrderIncID: Text; pDocNo: Code[50]; pCashReceiptAmount: Decimal; pPaymentDate: Date) // JAP - 07/29/2021
    var
        CustLedgerEntries: Record "Cust. Ledger Entry";
        CustLedgerEntries1: Record "Cust. Ledger Entry";
        lCRAmount: Decimal;
    begin
        lCRAmount := pCashReceiptAmount;

        CustLedgerEntries.Reset();
        CustLedgerEntries.SetCurrentKey("Due Date");
        CustLedgerEntries.SetRange("External Document No.", pOrderIncID);
        CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
        CustLedgerEntries.SetFilter("Applies-to ID", '%1', '');
        CustLedgerEntries.SetRange(Open, true);
        if CustLedgerEntries.FindSet() then
            repeat
                if (CustLedgerEntries."Applies-to ID" = '') and (CustLedgerEntries."Posting Date" < pPaymentDate) then
                    if lCRAmount > 0 then begin
                        CustLedgerEntries.CalcFields("Remaining Amount");
                        if CustLedgerEntries."Remaining Amount" > lCRAmount then begin
                            CustLedgerEntries1.Reset();
                            CustLedgerEntries1.SetRange("Document No.", CustLedgerEntries."Document No.");
                            CustLedgerEntries1.SetRange("External Document No.", pOrderIncID);
                            CustLedgerEntries1.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                            CustLedgerEntries1.SetRange("Entry No.", CustLedgerEntries."Entry No.");
                            if CustLedgerEntries1.FindFirst() then begin
                                CustLedgerEntries1.VALIDATE("Amount to Apply", lCRAmount);
                                CustLedgerEntries1.Modify();

                                lCRAmount := lCRAmount - CustLedgerEntries."Remaining Amount";

                                if lCRAmount <= 0 then begin
                                    TempCLERemaining.Init();
                                    TempCLERemaining.TransferFields(CustLedgerEntries1);
                                    TempCLERemaining.Insert();
                                end;
                            end;
                        end else begin
                            CustLedgerEntries1.Reset();
                            CustLedgerEntries1.SetRange("Document No.", CustLedgerEntries."Document No.");
                            CustLedgerEntries1.SetRange("External Document No.", pOrderIncID);
                            CustLedgerEntries1.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
                            CustLedgerEntries1.SetRange("Entry No.", CustLedgerEntries."Entry No.");
                            if CustLedgerEntries1.FindFirst() then begin
                                CustLedgerEntries1.VALIDATE("Amount to Apply", CustLedgerEntries."Remaining Amount");
                                CustLedgerEntries1.Modify();

                                lCRAmount := lCRAmount - CustLedgerEntries."Remaining Amount";
                            end;
                        end;
                    end;
            until CustLedgerEntries.Next() = 0;
        WithAppliedEntries := false;

        CustLedgerEntries.Reset();
        CustLedgerEntries.SetRange("External Document No.", pOrderIncID);
        CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
        CustLedgerEntries.SetFilter("Amount to Apply", ' <> %1', 0);
        CustLedgerEntries.SetFilter("Applies-to ID", '%1', '');
        CustLedgerEntries.ModifyAll("Applies-to ID", pDocNo); //SSLT - fixed orig pOrderIncID

        CustLedgerEntries.Reset();
        CustLedgerEntries.SetRange("External Document No.", pOrderIncID);
        CustLedgerEntries.SetRange("Document Type", CustLedgerEntries."Document Type"::Invoice);
        CustLedgerEntries.SetFilter("Applies-to ID", pDocNo);
        if CustLedgerEntries.FindFirst() then
            WithAppliedEntries := true;

    end;

    local procedure CreateItem(ItemNo: Code[20]; ItemDesc: Text[100]; UOM: Code[10]; GenProdPostingGrp: Code[20]; InventoryPostingGroup: Code[20]);
    var
        Item: Record Item;
    begin
        if ItemDesc = '' then
            ItemDesc := ItemNo;

        Item.Reset();
        Item.SetRange("Integration Item", ItemNo);
        if Item.IsEmpty then begin
            Item.Init();
            Item."No." := ItemNo;
            Item.Insert();
            Item.Validate("Integration Item", ItemNo);
            Item.Validate(Description, ItemDesc);
            Item.Validate("Base Unit of Measure", UOM);
            Item.Validate("Costing Method", Item."Costing Method"::Average);
            Item.Validate("Gen. Prod. Posting Group", GenProdPostingGrp);
            Item.Validate("Inventory Posting Group", InventoryPostingGroup);
            Item.Modify();
        end;
    end;
    //PTC001
    local procedure AssignDimensionSalesLine(Var SalesLine: Record "Sales Line"; DimCode: Code[20]; DimValue: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
        DimSetEntry: Record "Dimension Set Entry";
        NewDimSetID: Integer;
    begin

        if DimValue <> '' then begin
            NewDimSetID :=
                        DimMgt.SetDimensionValue(
                        SalesLine."Dimension Set ID",     // current set
                        DimCode,               // Dimension Code
                        DimValue,              // Dimension Value Code
                        false,                 // Create missing Dimension
                        false                  // Create missing Dimension Value
                        );

            SalesLine."Dimension Set ID" := NewDimSetID;
            SalesLine.Modify();
        end;
    end;

    var
        isSOPostedErrorMsg: Text;
        TempCLERemaining: Record "Cust. Ledger Entry" temporary;
        ToCreateItem: Boolean;


    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertCustomer_CreateCustomers(CustomerInvoiceStaging: Record "Customer and Invoice Staging")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePurchaseLineNo_CreatePurchInvoices(VendorInvoiceStaging: Record "Purchase Invoice Staging"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyPurchaseLine_CreatePurchInvoices(VendorInvoiceStaging: Record "Purchase Invoice Staging"; var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyAllError_CheckPurchInvoices(var VendorInvoiceStaging: Record "Purchase Invoice Staging")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateNo_CheckPurchInvoices(var VendorInvoiceStaging: Record "Purchase Invoice Staging"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateError_CheckPurchInvoices(var VendorInvoiceStaging: Record "Purchase Invoice Staging")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateSalesLineNo_CreateSalesInvoices(CustomerInvoiceStaging: Record "Customer and Invoice Staging"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesLine_CreateSalesInvoices(CustomerInvoiceStaging: Record "Customer and Invoice Staging"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyAllError_CheckSalesInvoices(var CustomerInvoiceStaging: Record "Customer and Invoice Staging")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateNo_CheckSalesInvoices(var CustomerInvoiceStaging: Record "Customer and Invoice Staging"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateError_CheckSalesInvoices(var CustomerInvoiceStaging: Record "Customer and Invoice Staging")
    begin
    end;


}

