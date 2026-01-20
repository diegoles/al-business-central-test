// Learning: This codeunit subscribes to Sales-Post events and writes loyalty ledger entries.
codeunit 70001 "Loyalty Management"
{
    Permissions = tabledata "Loyalty Ledger Entry" = rimd,
                  tabledata Customer = r,
                  tabledata "Sales Invoice Header" = r;

    // Learning: Toggle to enable/disable diagnostic telemetry logs in test environments.
    var
        EnableTestLogging: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    var
        Customer: Record Customer;
    begin
        LogDebug('OnBeforePostSalesDoc triggered.');
        // Validate the customer before posting to enforce the blocked rule.
        if SalesHeader."Sell-to Customer No." = '' then
            exit;
        // Load the customer linked to the sales document.
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
        // Block posting when the customer is Ship or All blocked.
        if (Customer.Blocked = Customer.Blocked::Ship) or (Customer.Blocked = Customer.Blocked::All) then
            Error('No se puede facturar para puntos a un cliente bloqueado.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean)
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        LogDebug(StrSubstNo('OnAfterPostSalesDoc triggered. SalesInvHdrNo=%1', SalesInvHdrNo));
        // Use the posted invoice number provided by Sales-Post.
        if SalesInvHdrNo = '' then
            exit;
        // Load the posted Sales Invoice Header to calculate points.
        if not SalesInvHeader.Get(SalesInvHdrNo) then
            exit;
        // Create the loyalty ledger entry from the posted invoice.
        InsertPointsFromInvoice(SalesInvHeader);
    end;

    local procedure InsertPointsFromInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        LoyaltyEntry: Record "Loyalty Ledger Entry";
        ExistingEntry: Record "Loyalty Ledger Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
        AmountIncludingVAT: Decimal;
        Points: Integer;
        PointsDecimal: Decimal;
    begin
        // Ensure the invoice is linked to a customer.
        if SalesInvoiceHeader."Sell-to Customer No." = '' then
            exit;
        // Get total amount including VAT from header; if 0, sum from lines.
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        AmountIncludingVAT := SalesInvoiceHeader."Amount Including VAT";
        if AmountIncludingVAT = 0 then begin
            SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
            if SalesInvoiceLine.FindSet() then
                repeat
                    AmountIncludingVAT += SalesInvoiceLine."Amount Including VAT";
                until SalesInvoiceLine.Next() = 0;
        end;
        // 1 point per 100 of the invoice total (rounded down).
        PointsDecimal := AmountIncludingVAT / 100;
        Points := Round(PointsDecimal, 1, '<');
        if Points <= 0 then
            exit;
        // Avoid duplicating points for the same invoice.
        ExistingEntry.SetRange("Customer No.", SalesInvoiceHeader."Sell-to Customer No.");
        ExistingEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        if not ExistingEntry.IsEmpty() then
            exit;
        // Insert a new loyalty ledger entry.
        LoyaltyEntry.Init();
        LoyaltyEntry."Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        LoyaltyEntry."Posting Date" := SalesInvoiceHeader."Posting Date";
        LoyaltyEntry."Document No." := SalesInvoiceHeader."No.";
        LoyaltyEntry.Points := Points;
        LoyaltyEntry.Description := StrSubstNo('Puntos por factura %1', SalesInvoiceHeader."No.");
        LoyaltyEntry.Insert();
        // Update the customer field requested in Part 1.
        AddPointsToCustomer(SalesInvoiceHeader."Sell-to Customer No.", Points);
        LogDebug(StrSubstNo('Inserted loyalty entry. Doc=%1 Points=%2', SalesInvoiceHeader."No.", Points));
    end;

    local procedure AddPointsToCustomer(CustomerNo: Code[20]; Points: Integer)
    var
        Customer: Record Customer;
    begin
        if (CustomerNo = '') or (Points <= 0) then
            exit;
        if not Customer.Get(CustomerNo) then
            exit;
        Customer."Loyalty Points" += Points;
        Customer.Modify();
    end;

    local procedure LogDebug(Message: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if not IsTestLoggingEnabled() then
            exit;
        Session.LogMessage('BCLOYALTY', Message, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure IsTestLoggingEnabled(): Boolean
    begin
        exit(true);
    end;

    procedure CreatePointsForInvoiceNo(InvoiceNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if InvoiceNo = '' then
            exit;
        if not SalesInvoiceHeader.Get(InvoiceNo) then
            exit;
        InsertPointsFromInvoice(SalesInvoiceHeader);
    end;
}
