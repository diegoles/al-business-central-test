// Learning: Ledger table that stores each loyalty points transaction per posted invoice or adjustment.
table 70000 "Loyalty Ledger Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; Points; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Customer; "Customer No.", "Posting Date") { }
    }
}
