table 50002 "Integration Setup"
{
    Caption = 'Integration Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Automatic Sales Posting"; Boolean)
        {
        }
        field(11; "Automatic Purchase Posting"; Boolean)
        {
        }
        field(12; "Automatic Cash Receipt Posting"; Boolean)
        {
        }
        field(13; "Cash Receipt Batch"; Code[20])
        {

            trigger OnLookup()
            begin
                GenJournalTemplate.SETRANGE("Page ID", 255);
                GenJournalTemplate.FINDFIRST;
                GenJnlBatch.SETRANGE("Journal Template Name", GenJournalTemplate.Name);
                IF PAGE.RUNMODAL(0, GenJnlBatch) = ACTION::LookupOK THEN BEGIN
                    "Cash Receipt Batch" := GenJnlBatch.Name;
                END;
            end;

            trigger OnValidate()
            begin
                GenJournalTemplate.SETRANGE("Page ID", 255);
                GenJournalTemplate.FINDFIRST;
                GenJnlBatch.GET(GenJournalTemplate.Name, "Cash Receipt Batch");
            end;
        }
        field(14; "Sales Gen. Prod Posting Group"; Code[20])
        {
            Caption = 'Sales Gen. Product Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Product Posting Group".Code;
            ValidateTableRelation = true;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
}

