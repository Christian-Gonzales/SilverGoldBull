xmlport 50007 "Import Item Transfer Staging"
{
    Caption = 'Import Item Transfer Staging';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(ItemTransferStaging; "Item Transfer Staging")
            {
                XmlName = 'Import';
                fieldelement(ExternalDocumentNo; ItemTransferStaging."External Document No.")
                {
                }
                fieldelement(PostingDate; ItemTransferStaging."Posting Date")
                {
                }
                fieldelement(FromItemNo; ItemTransferStaging."From Item No.")
                {
                }
                fieldelement(FromItemDescription; ItemTransferStaging."From Item Description")
                {
                }
                fieldelement(SKU; ItemTransferStaging.SKU)
                {
                }
                fieldelement(ToItemNo; ItemTransferStaging."To Item No.")
                {
                }
                fieldelement(ToItemDescription; ItemTransferStaging."To Item Description")
                {
                }
                fieldelement(ToMetalType; ItemTransferStaging."To Metal Type")
                {
                }
                fieldelement(Quantity; ItemTransferStaging.Quantity)
                {
                }
                trigger OnBeforeInsertRecord()
                var
                begin
                    //ItemTransferStaging."Imported By" := UserId;
                    //ItemTransferStaging."Date Imported" := CurrentDateTime;
                end;
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
