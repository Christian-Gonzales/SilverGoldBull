page 50005 "Payment Type Mapping"
{
    PageType = List;
    SourceTable = "Payment Type Mapping";
    UsageCategory = Administration;
    ApplicationArea = all;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = all;
                }
                field("Integration Currency Code"; "Integration Currency Code")
                {
                    ApplicationArea = all;
                }
                field("NAV Type"; "NAV Type")
                {
                    ApplicationArea = all;
                }
                field("NAV No."; "NAV No.")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }
}

