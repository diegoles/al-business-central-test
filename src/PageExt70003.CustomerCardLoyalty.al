// Learning: Shows Total Loyalty Points on the Customer Card.
pageextension 70003 "Customer Card Loyalty" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Loyalty Points"; Rec."Loyalty Points")
            {
                ApplicationArea = All;
                ToolTip = 'Puntos calculados automáticamente por las facturas registradas.';
                Editable = false;
            }

            field("Total Loyalty Points"; Rec."Total Loyalty Points")
            {
                ApplicationArea = All;
                ToolTip = 'Total de puntos acumulados del cliente (suma del Loyalty Ledger Entry).';
            }
        }
    }
}
