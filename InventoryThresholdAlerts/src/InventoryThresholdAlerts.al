table 50150 "MID Inventory Threshold"
{
    Caption = 'Inventory Threshold';
    DataClassification = CustomerContent;
    LookupPageId = "MID Inventory Thresholds";
    DrillDownPageId = "MID Inventory Thresholds";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            // blank = all locations together
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            // blank = all variants together
        }
        field(10; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            trigger OnValidate()
            begin
                Status := Status::" "; // re-check against the new minimum
            end;
        }
        field(11; "Alert Email"; Text[250])
        {
            Caption = 'Alert Email';
            ExtendedDatatype = EMail;
            // blank = the Inventory Alert Email on the location, then the default on Inventory Setup
        }
        field(12; Blocked; Boolean) { Caption = 'Blocked'; }
        field(20; Status; Enum "MID Threshold Status") { Caption = 'Status'; Editable = false; DataClassification = SystemMetadata; }
        field(21; "Last Checked Qty."; Decimal) { Caption = 'Last Checked Quantity'; Editable = false; DecimalPlaces = 0 : 5; DataClassification = SystemMetadata; }
        field(22; "Last Checked At"; DateTime) { Caption = 'Last Checked At'; Editable = false; DataClassification = SystemMetadata; }
        field(23; "Last Alert Sent At"; DateTime) { Caption = 'Last Alert Sent At'; Editable = false; DataClassification = SystemMetadata; }
        field(30; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Location Code", "Variant Code") { Clustered = true; }
    }
}

enum 50150 "MID Threshold Status"
{
    Extensible = false;
    value(0; " ") { Caption = ' '; }
    value(1; "Above Minimum") { Caption = 'Above minimum'; }
    value(2; "Alert Sent") { Caption = 'Below minimum - alert sent'; }
    value(3; "No Recipient") { Caption = 'Below minimum - no alert email set'; }
}

page 50150 "MID Inventory Thresholds"
{
    Caption = 'Inventory Thresholds';
    PageType = List;
    SourceTable = "MID Inventory Threshold";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.") { ToolTip = 'Item to watch.'; }
                field("Item Description"; Rec."Item Description") { ToolTip = 'Item description.'; }
                field("Location Code"; Rec."Location Code") { ToolTip = 'Location to check. Leave blank to check total inventory across all locations.'; }
                field("Variant Code"; Rec."Variant Code") { ToolTip = 'Variant to check. Leave blank for all variants.'; }
                field("Minimum Quantity"; Rec."Minimum Quantity") { ToolTip = 'An alert is sent once when inventory falls below this quantity.'; }
                field("Alert Email"; Rec."Alert Email") { ToolTip = 'Who to alert. Leave blank to use the location''s Inventory Alert Email, then the default on Inventory Setup.'; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Pause alerts for this line.'; }
                field(Status; Rec.Status) { ToolTip = 'Result of the last check.'; }
                field("Last Checked Qty."; Rec."Last Checked Qty.") { ToolTip = 'Inventory at the last check.'; }
                field("Last Checked At"; Rec."Last Checked At") { ToolTip = 'When the line was last checked.'; }
                field("Last Alert Sent At"; Rec."Last Alert Sent At") { ToolTip = 'When the last alert was emailed.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CheckNow)
            {
                Caption = 'Check Now';
                Image = Recalculate;
                ToolTip = 'Check every threshold now and send any alerts that are due.';
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"MID Inventory Threshold Check");
                    CurrPage.Update(false);
                end;
            }
            action(CreateJob)
            {
                Caption = 'Create Job Queue Entry';
                Image = Job;
                ToolTip = 'Create an on-hold recurring Job Queue Entry that runs the check every 15 minutes. Review it, then set it to Ready.';
                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.Init();
                    JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
                    JobQueueEntry."Object ID to Run" := Codeunit::"MID Inventory Threshold Check";
                    JobQueueEntry.Description := 'Inventory threshold alerts';
                    JobQueueEntry."Recurring Job" := true;
                    JobQueueEntry."No. of Minutes between Runs" := 15;
                    JobQueueEntry."Run on Mondays" := true;
                    JobQueueEntry."Run on Tuesdays" := true;
                    JobQueueEntry."Run on Wednesdays" := true;
                    JobQueueEntry."Run on Thursdays" := true;
                    JobQueueEntry."Run on Fridays" := true;
                    JobQueueEntry."Run on Saturdays" := true;
                    JobQueueEntry."Run on Sundays" := true;
                    JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
                    JobQueueEntry.Insert(true);
                    Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(CheckNow_Promoted; CheckNow) { }
            actionref(CreateJob_Promoted; CreateJob) { }
        }
    }
}

pageextension 50150 "MID Item Card Threshold" extends "Item Card"
{
    actions
    {
        addlast(navigation)
        {
            action(MIDInventoryThresholds)
            {
                ApplicationArea = All;
                Caption = 'Inventory Thresholds';
                Image = Alerts;
                ToolTip = 'Set the minimum quantities that trigger an alert email for this item.';
                RunObject = page "MID Inventory Thresholds";
                RunPageLink = "Item No." = field("No.");
            }
        }
    }
}

tableextension 50151 "MID Location Alert Email" extends Location
{
    fields
    {
        field(50150; "MID Inventory Alert Email"; Text[250])
        {
            Caption = 'Inventory Alert Email';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
    }
}

pageextension 50151 "MID Location Card Alert" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("MID Inventory Alert Email"; Rec."MID Inventory Alert Email")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who receives inventory threshold alerts for this location when a threshold line has no email of its own. Separate several addresses with semicolons.';
            }
        }
    }
}

tableextension 50152 "MID Inventory Setup Alert" extends "Inventory Setup"
{
    fields
    {
        field(50150; "MID Default Alert Email"; Text[250])
        {
            Caption = 'Default Inventory Alert Email';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
    }
}

pageextension 50152 "MID Inventory Setup Alert" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("MID Default Alert Email"; Rec."MID Default Alert Email")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who receives inventory threshold alerts when neither the threshold line nor its location has an alert email.';
            }
        }
    }
}

/// <summary>
/// Run from a recurring Job Queue Entry (Object Type Codeunit, ID 50150), or the Check Now action.
/// Each threshold line alerts once when inventory drops below its minimum, and re-arms when stock recovers.
/// </summary>
codeunit 50150 "MID Inventory Threshold Check"
{
    trigger OnRun()
    var
        Threshold: Record "MID Inventory Threshold";
    begin
        Threshold.SetRange(Blocked, false);
        if Threshold.FindSet(true) then
            repeat
                CheckThreshold(Threshold);
            until Threshold.Next() = 0;
    end;

    local procedure CheckThreshold(var Threshold: Record "MID Inventory Threshold")
    var
        Item: Record Item;
        Inventory: Decimal;
        Recipient: Text;
    begin
        if not Item.Get(Threshold."Item No.") then
            exit;
        if Threshold."Location Code" <> '' then
            Item.SetRange("Location Filter", Threshold."Location Code");
        if Threshold."Variant Code" <> '' then
            Item.SetRange("Variant Filter", Threshold."Variant Code");
        Item.CalcFields(Inventory);
        Inventory := Item.Inventory;

        Threshold."Last Checked Qty." := Inventory;
        Threshold."Last Checked At" := CurrentDateTime();

        if Inventory >= Threshold."Minimum Quantity" then
            Threshold.Status := Threshold.Status::"Above Minimum"
        else
            if Threshold.Status <> Threshold.Status::"Alert Sent" then begin // alert once per dip
                Recipient := GetRecipient(Threshold);
                if Recipient = '' then
                    Threshold.Status := Threshold.Status::"No Recipient"
                else
                    if SendAlert(Threshold, Item, Inventory, Recipient) then begin
                        Threshold.Status := Threshold.Status::"Alert Sent";
                        Threshold."Last Alert Sent At" := CurrentDateTime();
                    end;
            end;
        Threshold.Modify();
    end;

    local procedure GetRecipient(Threshold: Record "MID Inventory Threshold"): Text
    var
        Location: Record Location;
        InventorySetup: Record "Inventory Setup";
    begin
        if Threshold."Alert Email" <> '' then
            exit(Threshold."Alert Email");
        if Threshold."Location Code" <> '' then
            if Location.Get(Threshold."Location Code") then
                if Location."MID Inventory Alert Email" <> '' then
                    exit(Location."MID Inventory Alert Email");
        if InventorySetup.Get() then
            exit(InventorySetup."MID Default Alert Email");
        exit('');
    end;

    local procedure SendAlert(Threshold: Record "MID Inventory Threshold"; Item: Record Item; Inventory: Decimal; Recipient: Text): Boolean
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Where: Text;
        AllLocationsTxt: Label 'all locations';
        SubjectTxt: Label 'Inventory alert: %1 below minimum at %2', Comment = '%1 = item no., %2 = location';
        BodyTxt: Label '<p>%1 %2 has fallen to <b>%3</b> %4 at %5, below the minimum of %6.</p>', Comment = '%1 = item no., %2 = description, %3 = inventory, %4 = unit of measure, %5 = location, %6 = minimum';
    begin
        Where := Threshold."Location Code";
        if Where = '' then
            Where := AllLocationsTxt;
        if Threshold."Variant Code" <> '' then
            Where := Threshold."Variant Code" + ' / ' + Where;
        EmailMessage.Create(Recipient,
            StrSubstNo(SubjectTxt, Item."No.", Where),
            StrSubstNo(BodyTxt, Item."No.", Item.Description, Format(Inventory), Item."Base Unit of Measure", Where, Format(Threshold."Minimum Quantity")),
            true);
        exit(Email.Send(EmailMessage, Enum::"Email Scenario"::Default));
    end;
}

permissionset 50150 "MID INV ALERTS"
{
    Assignable = true;
    Caption = 'Inventory Threshold Alerts';
    IncludedPermissionSets = "Email - Edit";
    Permissions =
        tabledata "MID Inventory Threshold" = RIMD,
        table "MID Inventory Threshold" = X,
        page "MID Inventory Thresholds" = X,
        codeunit "MID Inventory Threshold Check" = X,
        tabledata Item = R,
        tabledata Location = R,
        tabledata "Inventory Setup" = R,
        tabledata "Item Ledger Entry" = R,
        tabledata "Job Queue Entry" = RIM;
}
