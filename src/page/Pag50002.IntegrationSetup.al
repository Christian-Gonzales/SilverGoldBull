page 50002 "Integration Setup"
{
    Caption = 'Integration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Automatic Sales Posting"; "Automatic Sales Posting")
                {
                    ApplicationArea = All;
                }
                field("Automatic Purchase Posting"; "Automatic Purchase Posting")
                {
                    ApplicationArea = All;
                }
                field("Automatic Cash Receipt Posting"; "Automatic Cash Receipt Posting")
                {
                    ApplicationArea = All;
                }
                field("Cash Receipt Batch"; "Cash Receipt Batch")
                {
                    ApplicationArea = All;
                }
                field("Sales Gen. Prod Posting Group"; "Sales Gen. Prod Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        RESET;
        IF NOT GET THEN BEGIN
            INIT;
            INSERT;
        END;
    end;
}

