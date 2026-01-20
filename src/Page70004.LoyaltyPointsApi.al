// Learning: API page exposing customer loyalty totals plus a service-enabled adjustment action.
page 70004 "Loyalty Points API"
{
    PageType = API;
    APIPublisher = 'ediaz';
    APIGroup = 'loyalty';
    APIVersion = 'v2.0';
    EntityName = 'loyaltyPoint';
    EntitySetName = 'loyaltyPoints';
    SourceTable = Customer;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata Customer = r,
                  tabledata "Loyalty Ledger Entry" = rimd;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                }
                field(number; Rec."No.")
                {
                    Caption = 'number';
                }
                field(name; Rec.Name)
                {
                    Caption = 'name';
                }
                field(totalLoyaltyPoints; Rec."Total Loyalty Points")
                {
                    Caption = 'totalLoyaltyPoints';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Total Loyalty Points");
    end;

    [ServiceEnabled]
    procedure AdjustLoyaltyPoints(Points: Integer; Description: Text[100])
    var
        LoyaltyEntry: Record "Loyalty Ledger Entry";
    begin
        if Points = 0 then
            exit;
        Rec.TestField("No.");

        LoyaltyEntry.Init();
        LoyaltyEntry."Customer No." := Rec."No.";
        LoyaltyEntry."Posting Date" := Today;
        LoyaltyEntry."Document No." := '';
        LoyaltyEntry.Points := Points;
        LoyaltyEntry.Description := Description;
        LoyaltyEntry.Insert();
    end;
}
