codeunit 50006 ItemTransferMgmt
{

    var

        Text50000: Label 'The %1 must have a value.';
        Text50001: Label '%1 %2 does not exist.';
        Text50002: Label 'The %1 %2 has no Posting Group.';
        Text50006: Label 'Nothing is created.';
        Text50010: Label 'There are %1 lines and %2 lines have errors.';
        Text50011: Label 'Do you want to create Item and Assembly Order?';
        ToCreateItem: Boolean;


    procedure Check()
    begin
        CheckItemTransfer(true);
    end;

    procedure Create()
    begin
        if not confirm(Text50011, false) then begin
            Message(Text50006);
            exit
        end;

        ToCreateItem := true;
        CheckItemTransfer(false);
        //CreateItem();
        CreateItemTransfer();
    end;

    local procedure CheckItem()
    var
        ItemTransfer: Record "Item Transfer Staging";
        Item: Record Item;
    begin
        ItemTransfer.Reset();
        ItemTransfer.SetRange(Processed, false);

        if ItemTransfer.FindFirst() then
            repeat
                ItemTransfer."Error Message" := '';

                Item.Reset();
                Item.SetRange("Integration Item", UpperCase(ItemTransfer."From Item No."));
                if Item.IsEmpty then begin
                    ItemTransfer."Error Message" += StrSubstNo(Text50001, ItemTransfer.FieldCaption("From Item No."), ItemTransfer."From Item No.") + '; ';
                end;

                Item.Reset();
                Item.SetRange("Integration Item", UpperCase(ItemTransfer."To Item No."));
                if Item.IsEmpty then begin
                    ItemTransfer."Error Message" += StrSubstNo(Text50001, ItemTransfer.FieldCaption("To Item No."), ItemTransfer."To Item No.") + '; ';
                end;

                ItemTransfer.Modify();

            until ItemTransfer.Next() = 0;
    end;

    local procedure CreateItem()
    var
        ItemTransfer: Record "Item Transfer Staging";
        Item: Record Item;
    begin
        ItemTransfer.Reset();
        ItemTransfer.SetRange(Processed, false);

        if ItemTransfer.FindFirst() then
            repeat
                // Item.Reset();
                // Item.SetRange("Integration Item", ItemTransfer."From Item No.");
                // if Item.IsEmpty then begin
                //     Item.Init();
                //     Item."No." := ItemTransfer."From Item No.";
                //     Item.Validate("Integration Item", ItemTransfer."From Item No.");
                //     Item.Validate(Description, ItemTransfer."From Item Description");
                //     Item.Validate("Costing Method", Item."Costing Method"::Average);
                //     Item.Validate("Inventory Posting Group", ItemTransfer."Inventory Posting Group");
                //     Item.Insert();
                // end;

                Item.Reset();
                Item.SetRange("Integration Item", ItemTransfer."To Item No.");
                if Item.IsEmpty then begin
                    Item.Init();
                    Item."No." := ItemTransfer."To Item No.";
                    Item.Insert();
                    Item.Validate("Integration Item", ItemTransfer."To Item No.");
                    Item.Validate(Description, ItemTransfer."To Item Description");
                    Item.Validate("Base Unit of Measure", ItemTransfer."To Base Unit of Measure");
                    Item.Validate("Costing Method", Item."Costing Method"::Average);
                    Item.Validate("Inventory Posting Group", ItemTransfer."To Inventory Posting Group");
                    Item.Validate("Gen. Prod. Posting Group", ItemTransfer."To Gen. Prod. Posting Group");
                    Item.Modify();
                end;

            until ItemTransfer.Next() = 0;
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


    local procedure CheckItemTransfer(ShowMessage: Boolean)
    var
        ItemTransfer: Record "Item Transfer Staging";
        Item: Record Item;
        TotalLine: Integer;
        ErrorLine: Integer;
    begin
        ItemTransfer.Reset();
        ItemTransfer.SetRange(Processed, false);
        TotalLine := ItemTransfer.Count;
        ErrorLine := 0;

        ItemTransfer.ModifyAll("Error Message", '');

        if ItemTransfer.FindFirst() then
            repeat

                if not ToCreateItem then begin
                    Item.Reset();
                    Item.SetRange("Integration Item", UpperCase(ItemTransfer."To Item No."));
                    if Item.IsEmpty then begin
                        ItemTransfer."Error Message" += StrSubstNo(Text50001, ItemTransfer.FieldCaption("To Item No."), ItemTransfer."To Item No.") + '; ';
                    end;
                end;

                Item.Reset();
                Item.SetRange("Integration Item", UpperCase(ItemTransfer."From Item No."));
                if Item.IsEmpty then begin
                    ItemTransfer."Error Message" += StrSubstNo(Text50001, ItemTransfer.FieldCaption("From Item No."), ItemTransfer."From Item No.") + '; ';
                end;


                if ItemTransfer.Quantity = 0 then
                    ItemTransfer."Error Message" += StrSubstNo(Text50000, ItemTransfer.FieldCaption(Quantity)) + '; ';

                Item := GetItemRec(ItemTransfer."To Item No.");

                if ItemTransfer."To Base Unit of Measure" = '' then
                    ItemTransfer."Error Message" += StrSubstNo(Text50000, ItemTransfer.FieldCaption("To Base Unit of Measure")) + '; ';

                if ItemTransfer."To Gen. Prod. Posting Group" = '' then
                    ItemTransfer."Error Message" += StrSubstNo(Text50000, ItemTransfer.FieldCaption("To Gen. Prod. Posting Group")) + '; ';


                if Item.Type = Item.Type::Inventory then
                    if ItemTransfer."To Inventory Posting Group" = '' then
                        ItemTransfer."Error Message" += StrSubstNo(Text50000, ItemTransfer.FieldCaption("To Inventory Posting Group")) + '; ';

                if ItemTransfer."Error Message" <> '' then
                    ErrorLine += 1;

                ItemTransfer.Modify();
            until ItemTransfer.Next() = 0;

        Commit();

        IF ShowMessage THEN
            Message(Text50010, TotalLine, ErrorLine);

        // if ErrorLine <> 0 then
        //     Error('');
    end;

    local procedure CreateItemTransfer()
    var
        ItemTransfer: Record "Item Transfer Staging";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        Item: Record Item;
    begin
        ItemTransfer.Reset();
        ItemTransfer.SetRange(Processed, false);
        ItemTransfer.SetRange("Document Has Error", false);

        if ItemTransfer.FindFirst() then
            repeat
                CreateItem(ItemTransfer."To Item No.", ItemTransfer."To Item Description", ItemTransfer."To Base Unit of Measure", ItemTransfer."To Gen. Prod. Posting Group", ItemTransfer."To Inventory Posting Group");

                AssemblyHeader.Init();
                AssemblyHeader."Document Type" := AssemblyHeader."Document Type"::Order;
                InitRecord(AssemblyHeader);
                AssemblyHeader."No." := ItemTransfer."External Document No.";
                AssemblyHeader.Insert();

                AssemblyHeader.Validate("Posting Date", ItemTransfer."Posting Date");
                AssemblyHeader.Validate("Due Date", ItemTransfer."Posting Date");
                AssemblyHeader.Validate("Item No.", GetItemNo(ItemTransfer."To Item No."));
                AssemblyHeader.Validate(Quantity, ItemTransfer.Quantity);
                AssemblyHeader.Modify();

                AssemblyLine.Init();
                AssemblyLine."Document Type" := AssemblyHeader."Document Type";
                AssemblyLine."Document No." := AssemblyHeader."No.";
                AssemblyLine."Line No." := 10000;
                AssemblyLine.Insert();

                AssemblyLine.Validate(Type, AssemblyLine.Type::Item);
                AssemblyLine.Validate("No.", GetItemNo(ItemTransfer."From Item No."));
                AssemblyLine.Validate("Quantity per", 1);
                AssemblyLine.SKU := ItemTransfer.SKU;
                AssemblyLine.Modify();

                ItemTransfer.Processed := true;
                ItemTransfer."Process By" := UserId;
                ItemTransfer."Date Processed" := CurrentDateTime;
                ItemTransfer.Modify()
            until ItemTransfer.Next() = 0;
    end;

    local procedure GetItemNo(IntegrationItem: Code[30]): Code[20]
    var
        lItem: Record Item;
    begin
        lItem.Reset();
        lItem.SetRange("Integration Item", IntegrationItem);
        if lItem.FindFirst() then
            exit(lItem."No.");
    end;

    local procedure GetItemRec(IntegrationItem: Code[30]): Record Item;
    var
        lItem: Record Item;
    begin
        lItem.Reset();
        lItem.SetRange("Integration Item", IntegrationItem);
        if lItem.FindFirst() then
            exit(lItem);
    end;

    procedure RegenerateItemTransferStaging(var ItemTransferStaging: Record "Item Transfer Staging")
    var
        lItemTransferStaging: Record "Item Transfer Staging";
    begin
        if ItemTransferStaging.FindFirst() then
            repeat
                Clear(lItemTransferStaging);
                lItemTransferStaging.Init();
                lItemTransferStaging."External Document No." := ItemTransferStaging."External Document No.";
                lItemTransferStaging."Posting Date" := ItemTransferStaging."Posting Date";
                lItemTransferStaging."From Item No." := ItemTransferStaging."From Item No.";
                lItemTransferStaging."From Item Description" := ItemTransferStaging."From Item Description";
                lItemTransferStaging."To Item No." := ItemTransferStaging."To Item No.";
                lItemTransferStaging."To Item Description" := ItemTransferStaging."To Item Description";
                lItemTransferStaging.Quantity := ItemTransferStaging.Quantity;
                lItemTransferStaging."To Base Unit of Measure" := ItemTransferStaging."To Base Unit of Measure";
                lItemTransferStaging."To Gen. Prod. Posting Group" := ItemTransferStaging."To Gen. Prod. Posting Group";
                lItemTransferStaging."To Inventory Posting Group" := ItemTransferStaging."To Inventory Posting Group";
                lItemTransferStaging."Regenerated From Entry No." := ItemTransferStaging."Entry No.";
                lItemTransferStaging.Insert();
            until ItemTransferStaging.Next() = 0;
    end;

    local procedure InitRecord(var AssemblyHeader: Record "Assembly Header")
    var
        NoSeries: Codeunit "No. Series";
        AssemblySetup: Record "Assembly Setup";
    begin
        AssemblySetup.Get();
        case AssemblyHeader."Document Type" of
            AssemblyHeader."Document Type"::Quote, AssemblyHeader."Document Type"::"Blanket Order":
                if NoSeries.IsAutomatic(AssemblySetup."Posted Assembly Order Nos.") then
                    AssemblyHeader."Posting No. Series" := AssemblySetup."Posted Assembly Order Nos.";
            AssemblyHeader."Document Type"::Order:
                if (AssemblyHeader."No. Series" <> '') and
                    (AssemblySetup."Assembly Order Nos." = AssemblySetup."Posted Assembly Order Nos.")
                then
                    AssemblyHeader."Posting No. Series" := AssemblyHeader."No. Series"
                else
                    if NoSeries.IsAutomatic(AssemblySetup."Posted Assembly Order Nos.") then
                        AssemblyHeader."Posting No. Series" := AssemblySetup."Posted Assembly Order Nos.";
        end;

        AssemblyHeader."Creation Date" := WorkDate();
        if AssemblyHeader."Due Date" = 0D then
            AssemblyHeader."Due Date" := WorkDate();
        AssemblyHeader."Posting Date" := WorkDate();
        if AssemblyHeader."Starting Date" = 0D then
            AssemblyHeader."Starting Date" := WorkDate();
        if AssemblyHeader."Ending Date" = 0D then
            AssemblyHeader."Ending Date" := WorkDate();

        SetDefaultLocation(AssemblyHeader);

    end;

    local procedure SetDefaultLocation(var AssemblyHeader: Record "Assembly Header")
    var
        AsmSetup: Record "Assembly Setup";
    begin
        if AsmSetup.Get() then
            if AsmSetup."Default Location for Orders" <> '' then
                if AssemblyHeader."Location Code" = '' then
                    AssemblyHeader.Validate("Location Code", AsmSetup."Default Location for Orders");
    end;


}
