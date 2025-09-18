pageextension 50005 "SS Posted Sales Invoice Lines" extends "Posted Sales Invoice Lines"  //526
{
    layout
    {
        addlast(Control1)
        {
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = Basic, Suite;
            }
            field("External Document No."; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field(UnitPriceLCY; UnitPriceLCY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unit Price (LCY)';
            }
            field(AmountLCY; AmountLCY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount (LCY)';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Currency Factor");
        if Rec."Currency Factor" <> 0 then begin
            UnitPriceLCY := Rec."Unit Price" / Rec."Currency Factor";
            AmountLCY := Rec."Amount Including VAT" / Rec."Currency Factor";
        end;
    end;

    var
        UnitPriceLCY: Decimal;
        AmountLCY: Decimal;
}
