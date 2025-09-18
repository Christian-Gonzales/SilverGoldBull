pageextension 50023 "DirectDebitCollections" extends "Direct Debit Collections"  //1207
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        modify(NewCollection)
        {
            Visible = false;
        }
        addafter(NewCollection)
        {
            action(NewCollection2)
            {
                ApplicationArea = Suite;
                Caption = 'Create Direct Debit Collection';
                Image = NewInvoice;
                Promoted = true;
                PromotedCategory = New;
                RunObject = Report "Create Direct Debit Collect.";
                ToolTip = 'Create a direct-debit collection to collect invoice payments directly from a customer''s bank account based on direct-debit mandates.';
            }
        }

    }

    var
        myInt: Integer;
}