report 50007 "Detailed Revenue Report"
{
    ApplicationArea = All;
    Caption = 'Detailed Revenue Report';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep50007.DetailedRevenueReport.rdlc';

    dataset
    {
        dataitem(SalesInvoiceLine; "Sales Invoice Line")
        {
            UseTemporary = true;
            //RequestFilterFields = "Posting Date", "Document No.";
            DataItemTableView = sorting("Document No.", "Line No.");

            column(CompanyName; CompanyInfo.Name)
            {
            }
            column(ProcessedTime; ProcessedTime)
            {
            }
            column(PostingDateFilter; PostingDateFilter)
            {
            }
            column(GLAccountNoFilter; GLAccountNoFilter)
            {
            }
            column(DocumentNoFilter; DocumentNoFilter)
            {
            }
            column(GLAccountNo; "Allocation Account No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(ExternalDocumentNo; "External Document No.")
            {
            }
            column(ItemNo; "No.")
            {
            }
            column(Description; Description)
            {
            }
            column(SKU; "SKU")
            {
            }
            column(SelltoCustomerNo; "Sell-to Customer No.")
            {
            }
            column(SelltoCustomerName; GetCustomerName("Sell-to Customer No."))
            {
            }
            column(Quantity; Quantity)
            {
            }
            column(UnitPrice; "Unit Price")
            {
            }
            column(UnitPriceLCY; "Unit Cost")// Unit Price (LCY)
            {
            }
            column(Amount; Amount)
            {
            }
            column(AmountLCY; "Unit Cost (LCY)") // Amount (LCY)
            {
            }
            column(RegionCode; "Shortcut Dimension 1 Code")
            {
            }
            trigger OnPreDataItem()
            var
            begin
                CompanyInfo.Get;
                FromTime := Time;
                PopulateGLAccount();
                PopulateData;
            end;

            trigger OnPostDataItem()
            begin
                ProcessedTime := Time - FromTime;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    //Caption = 'Filter';
                    field(PostingDateFilter; PostingDateFilter)
                    {
                        Caption = 'Posting Date';
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            FilterTokens.MakeDateFilter(PostingDateFilter);
                        end;
                    }
                    field(GLAccountNoFilter; GLAccountNoFilter)
                    {
                        Caption = 'G/L Account No.';
                        ApplicationArea = All;
                        TableRelation = "G/L Account";
                    }
                    field(DocumentNoFilter; DocumentNoFilter)
                    {
                        Caption = 'Document No.';
                        ApplicationArea = All;
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }

        trigger OnOpenPage()
        begin

        end;
    }

    local procedure GetCustomerName(CustomerCode: Code[20]): Text[100]
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerCode) then
            exit(Customer.Name);
    end;

    local procedure GetPostingGLAcct(Type: Option Invoice,"Credit Memo"; GenBusPostGrp: Code[20]; GenProdPostGrp: Code[20]): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        if GenPostingSetup.Get(GenBusPostGrp, GenProdPostGrp) then
            case Type of
                Type::Invoice:
                    exit(GenPostingSetup."Sales Account");
                Type::"Credit Memo":
                    exit(GenPostingSetup."Sales Credit Memo Account")
            end;
    end;

    local procedure PopulateData()
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCMLine: Record "Sales Cr.Memo Line";
        GLEntry: Record "G/L Entry";
        lGLAcctNo: Code[20];
    begin
        SalesInvLine.Reset();
        SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account");
        SalesInvLine.SetFilter("Posting Date", PostingDateFilter);
        SalesInvLine.SetFilter("Document No.", DocumentNoFilter);
        if SalesInvLine.FindFirst() then
            repeat
                if SalesInvLine.Type = SalesInvLine.Type::"G/L Account" then
                    lGLAcctNo := SalesInvLine."No."
                else
                    lGLAcctNo := GetPostingGLAcct(0, SalesInvLine."Gen. Bus. Posting Group", SalesInvLine."Gen. Prod. Posting Group");

                GLAccountTemp.Reset();
                GLAccountTemp.SetRange("No.", lGLAcctNo);
                if not GLAccountTemp.IsEmpty then begin

                    SalesInvLine."Unit Cost" := SalesInvLine."Unit Price";
                    SalesInvLine."Unit Cost (LCY)" := SalesInvLine.Amount;

                    SalesInvLine.CalcFields("External Document No.", "Currency Factor");
                    if SalesInvLine."Currency Factor" <> 0 then begin
                        SalesInvLine."Unit Cost" := SalesInvLine."Unit Price" / SalesInvLine."Currency Factor"; // Unit Price (LCY)
                        SalesInvLine."Unit Cost (LCY)" := SalesInvLine.Amount / SalesInvLine."Currency Factor"; // Amount (LCY)
                    end;

                    SalesInvoiceLine.Init();
                    SalesInvoiceLine.TransferFields(SalesInvLine);
                    SalesInvoiceLine."Allocation Account No." := lGLAcctNo;
                    SalesInvoiceLine.Insert();
                end;
            until SalesInvLine.Next() = 0;

        SalesCMLine.Reset();
        SalesCMLine.SetFilter(Type, '%1|%2', SalesCMLine.Type::Item, SalesCMLine.Type::"G/L Account");
        SalesCMLine.SetFilter("Posting Date", PostingDateFilter);
        SalesCMLine.SetFilter("Document No.", DocumentNoFilter);
        if SalesCMLine.FindFirst() then
            repeat
                if SalesCMLine.Type = SalesCMLine.Type::"G/L Account" then
                    lGLAcctNo := SalesCMLine."No."
                else
                    lGLAcctNo := GetPostingGLAcct(0, SalesCMLine."Gen. Bus. Posting Group", SalesCMLine."Gen. Prod. Posting Group");

                GLAccountTemp.Reset();
                GLAccountTemp.SetRange("No.", lGLAcctNo);
                if not GLAccountTemp.IsEmpty then begin
                    SalesCMLine.Quantity := -SalesCMLine.Quantity;
                    SalesCMLine."Unit Price" := -SalesCMLine."Unit Price";
                    SalesCMLine.Amount := -SalesCMLine.Amount;

                    SalesCMLine."Unit Cost" := SalesCMLine."Unit Price";
                    SalesCMLine."Unit Cost (LCY)" := SalesCMLine.Amount;

                    SalesCMLine.CalcFields("External Document No.", "Currency Factor");
                    if SalesCMLine."Currency Factor" <> 0 then begin
                        SalesCMLine."Unit Cost" := SalesCMLine."Unit Price" / SalesCMLine."Currency Factor"; // Unit Price (LCY)
                        SalesCMLine."Unit Cost (LCY)" := SalesCMLine.Amount / SalesCMLine."Currency Factor"; // Amount (LCY)
                    end;

                    SalesInvoiceLine.Init();
                    SalesInvoiceLine.TransferFields(SalesCMLine);
                    SalesInvoiceLine."Allocation Account No." := lGLAcctNo;
                    SalesInvoiceLine.Insert();
                end;

            until SalesCMLine.Next() = 0;


        GLEntry.Reset();
        GLEntry.SetFilter("Posting Date", PostingDateFilter);
        GLEntry.SetFilter("Source Code", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8&<>%9&<>%10',
            'CLSINCOME', 'SALES', 'BANKDEP', 'BANKREC', 'BANKRECADJ', 'COMPRBANK', 'BANKRECADJ', 'PAYMTRECON', 'RECLASSJNL', 'WHRCLSSJNL');
        if GLEntry.FindFirst() then
            repeat
                lGLAcctNo := GLEntry."G/L Account No.";
                GLAccountTemp.Reset();
                GLAccountTemp.SetRange("No.", lGLAcctNo);
                if not GLAccountTemp.IsEmpty then begin
                    SalesInvoiceLine.Init();
                    SalesInvoiceLine."Document No." := GLEntry."Document No.";
                    SalesInvoiceLine."Line No." := GLEntry."Entry No.";
                    SalesInvoiceLine."Sell-to Customer No." := GLEntry."Bal. Account No.";
                    SalesInvoiceLine."Posting Date" := GLEntry."Posting Date";
                    SalesInvoiceLine.Quantity := -1;
                    SalesInvoiceLine."Unit Price" := -GLEntry.Amount;
                    SalesInvoiceLine.Amount := -GLEntry.Amount;
                    SalesInvoiceLine."Unit Cost" := -GLEntry.Amount;
                    SalesInvoiceLine."Unit Cost (LCY)" := -GLEntry.Amount;
                    SalesInvoiceLine."Allocation Account No." := lGLAcctNo;
                    SalesInvoiceLine."Shortcut Dimension 1 Code" := GLEntry."Global Dimension 1 Code";
                    SalesInvoiceLine.Insert();
                end;
            until GLEntry.Next() = 0;

    end;

    procedure PopulateGLAccount()
    var
        lGLAccount: Record "G/L Account";
    begin
        GLAccountTemp.Reset();
        GLAccountTemp.DeleteAll();
        lGLAccount.Reset();
        lGLAccount.SetFilter("No.", GLAccountNoFilter);
        if lGLAccount.FindFirst() then
            repeat
                GLAccountTemp.Init();
                GLAccountTemp."No." := lGLAccount."No.";
                GLAccountTemp.Insert();
            until lGLAccount.Next() = 0;
    end;

    var
        GLAccountTemp: Record "G/L Account" temporary;
        PostingDateFilter: Text;
        GLAccountNoFilter: Text;
        DocumentNoFilter: Text;
        FromTime: Time;
        ProcessedTime: Duration;
        FilterTokens: Codeunit "Filter Tokens";
        CompanyInfo: Record "Company Information";
}
