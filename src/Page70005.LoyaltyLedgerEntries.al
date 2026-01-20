// Learning: List page for auditing loyalty ledger entries.
page 70005 "Loyalty Ledger Entries"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Loyalty Ledger Entry";
    UsageCategory = Lists;
    Caption = 'Loyalty Ledger Entries';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(Points; Rec.Points)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
