table 50004 "Payment Type Mapping"
{

    fields
    {
        field(1; "Payment Type"; Code[50])
        {
            NotBlank = true;
        }
        field(5; "NAV Type"; Option)
        {
            OptionCaption = ' ,G/L Account,Bank Account';
            OptionMembers = " ","G/L Account","Bank Account";
        }
        field(10; "NAV No."; Code[50])
        {
            TableRelation = IF ("NAV Type" = CONST("G/L Account")) "G/L Account" ELSE
            IF ("NAV Type" = CONST("Bank Account")) "Bank Account";
        }
        field(15; "Integration Currency Code"; Code[50])
        {
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Payment Type", "Integration Currency Code")
        {
        }
    }

    fieldgroups
    {
    }
}

