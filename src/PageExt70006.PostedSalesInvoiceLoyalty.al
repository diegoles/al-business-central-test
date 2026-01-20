// Learning: Diagnostic action to manually generate loyalty points for a posted invoice.
pageextension 70006 "Posted Sales Invoice Loyalty" extends "Posted Sales Invoice"
{
    actions
    {
        addlast(Processing)
        {
            action(GenerateLoyaltyPoints)
            {
                ApplicationArea = All;
                Caption = 'Generar puntos (diagnóstico)';
                Image = Calculate;
                ToolTip = 'Genera puntos para esta factura registrada.';

                trigger OnAction()
                var
                    LoyaltyMgmt: Codeunit "Loyalty Management";
                begin
                    LoyaltyMgmt.CreatePointsForInvoiceNo(Rec."No.");
                end;
            }
        }
    }
}
