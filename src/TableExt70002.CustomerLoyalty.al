// Learning: FlowField that sums loyalty points from the ledger table for each customer.
tableextension 70002 "Customer Loyalty" extends Customer
{
    fields
    {
        field(70001; "Loyalty Points"; Integer)
        {
            Caption = 'Loyalty Points';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(70000; "Total Loyalty Points"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Loyalty Ledger Entry".Points where("Customer No." = field("No.")));
            Caption = 'Total Loyalty Points';
            Editable = false;
        }
    }
}
