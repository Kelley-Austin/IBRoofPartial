@istest
public class SageTestFactory {
    
    public Salesperson__c salesperson;
    public Sales_Plan__c salesPlan;
    public Account acc;
    public Contact theContact;
    public Fulfillment__c fulfillment;
    public Customer_Sales_History__c customerSalesHistory;
    public Historical_Sales__c historicalSales;
    public Historical_Sale_Details__c historicalSaleDetails;
    public Open_Invoice__c openInvoice;
    public DailyShipment__c dailyShipment;
    //TODO: create other objects follow patern:
    
    public Salesperson__c createSalesperson(Boolean doInsert, String salespersonDivisionNo, String salespersonNo){
        
        this.salesperson = new Salesperson__c(); // TODO: Map fields

        this.salesperson.External_Id__c = salespersonDivisionNo + '-' + salespersonNo;
        this.salesperson.SalespersonDivisionNo__c = salespersonDivisionNo;
        this.salesperson.SalespersonNo__c = salespersonNo;
        this.salesperson.SalespersonName__c = 'test';
        this.salesperson.AddressLine1__c = 'test';
        this.salesperson.AddressLine2__c = 'test';
        this.salesperson.AddressLine3__c = 'test';
        this.salesperson.City__c = 'test';
        this.salesperson.State__c = 'test';
        this.salesperson.ZipCode__c = '00000';
        this.salesperson.CountryCode__c = 'USA';
        this.salesperson.TelephoneNo__c = '123-456-7890';
        this.salesperson.TelephoneExt__c = '123';
        this.salesperson.EmailAddress__c = 'test@email.com';
        this.salesperson.SalesManagerDivisionNo__c = '00';
        this.salesperson.SalesManagerNo__c = 'D7';
        this.salesperson.CRMUserID__c = '28';
        this.salesperson.CommissionRate__c = '0000000089';
        this.salesperson.SalesManagerCommRate__c = '0';
        this.salesperson.UDF_REWARD_ACCOUNT__c = 'HA1208';
        this.salesperson.Name__c = 'test';
        this.salesperson.Name = 'test';
        
        if (doInsert == true){
            insert this.salesperson;
        }
        return this.salesperson;
    }
    
    public Sales_Plan__c createSalesPlan(Boolean doInsert, Salesperson__c salesperson ){
        this.salesPlan = new Sales_Plan__c();
        this.salesPlan.Salesperson_Id__c = salesperson.id;
        this.salesPlan.Year__c = String.valueOf(Date.today().year());
        this.salesPlan.Jan_Goal__c = 100;
        this.salesPlan.Feb_Goal__c = 100;
        this.salesPlan.Mar_Goal__c = 100;
        this.salesPlan.Apr_Goal__c = 100;
        this.salesPlan.May_Goal__c = 100;
        this.salesPlan.Jun_Goal__c = 100;
        this.salesPlan.Jul_Goal__c = 100;
        this.salesPlan.Aug_Goal__c = 100;
        this.salesPlan.Sep_Goal__c = 100;
        this.salesPlan.Oct_Goal__c = 100;
        this.salesPlan.Nov_Goal__c = 100;
        this.salesPlan.Dec_Goal__c = 100;
        this.salesPlan.Jan_Quota__c = 100;
        this.salesPlan.Feb_Quota__c = 100;
        this.salesPlan.Mar_Quota__c = 100;
        this.salesPlan.Apr_Quota__c = 100;
        this.salesPlan.May_Quota__c = 100;
        this.salesPlan.Jun_Quota__c = 100;
        this.salesPlan.Jul_Quota__c = 100;
        this.salesPlan.Aug_Quota__c = 100;
        this.salesPlan.Sep_Quota__c = 100;
        this.salesPlan.Oct_Quota__c = 100;
        this.salesPlan.Nov_Quota__c = 100;
        this.salesPlan.Dec_Quota__c = 100;
        
        if (doInsert == true){
            insert this.salesPlan;
        }
        return this.salesPlan;
    }

    public Account createAccount(Boolean doInsert, Salesperson__c salesperson, String arDivisionNo, String customerNo){
        
        this.acc = new Account(); // TODO: Map fields
        
        //this.acc.Sage_Salesperson_No__c = salesperson.Id;

        this.acc.External_Id__c = arDivisionNo + '-' + customerNo;
        this.acc.SalespersonDivisionNo__c = salesperson.SalespersonDivisionNo__c;
        this.acc.SalespersonNo__c = salesperson.SalespersonNo__c;
        this.acc.Name = 'test';
        this.acc.BillingStreet = 'test';
        this.acc.BillingCity = 'test';
        this.acc.BillingState = 'test';
        this.acc.BillingPostalCode = '00000';
        this.acc.ARDivisionNo__c = arDivisionNo;
        this.acc.CustomerNo__c = customerNo;
        this.acc.CustomerName__c = 'test';
        this.acc.AddressLine1__c = 'test';
        this.acc.AddressLine2__c = 'test';
        this.acc.AddressLine3__c = 'test';
        this.acc.City__c = 'test';
        this.acc.State__c = 'test';
        this.acc.ZipCode__c = '00000';
        this.acc.CountryCode__c = 'USA';
        this.acc.TelephoneNo__c = '123-456-7890';
        this.acc.TelephoneExt__c = '123';
        this.acc.FaxNo__c = '123-456-7890';
        this.acc.EmailAddress__c = 'test@email.com';
        this.acc.URLAddress__c = 'test.com';
        this.acc.CustomerType__c = 'NEW';
        this.acc.PriceLevel__c = 'test';
        this.acc.DateLastActivity__c = '2020-01-01';
        this.acc.DateLastPayment__c = '2020-01-01';
        this.acc.DateLastStatement__c = '2020-01-01';
        this.acc.DateLastFinanceChrg__c = '2020-01-01';
        this.acc.DateLastAging__c = '2020-01-01 00:00:00.0000000';
        this.acc.CreditHold__c = 'N';
        this.acc.TermsCode__c = '27';
        this.acc.UDF_REGION__c = 'W';
        this.acc.UDF_TECHREP__c = '001';
        this.acc.UDF_GEARPOINTSAVAILABLE__c = '86.55';
        this.acc.UDF_ACCOUNT_STATUS__c = 'New Customer';
        this.acc.UDF_EMAILS__c = 'test@email.com';
        this.acc.UDF_TERRITORY__c = '01';
        this.acc.UDF_IB_COOPPOINTSAVAILABLE__c = '10.00';
        this.acc.UDF_IB_COOPSQ__c = '20.00';
        this.acc.CreditLimit__c = '30.00';
        
        if (doInsert == true){
            insert this.acc;
        }
        return this.acc;
    }

    public Contact createContact(Boolean doInsert, Account acct, String contactCode){
        
        this.theContact = new Contact(); // TODO: Map fields

        this.theContact.Sage_Contact_Code__c = acct.ARDivisionNo__c + '-' + acct.CustomerNo__c + '-' + contactCode;
        this.theContact.ARDivisionNo__c = acct.ARDivisionNo__c;
        this.theContact.CustomerNo__c = acct.CustomerNo__c;
        this.theContact.ContactCode__c = contactCode;
        this.theContact.ContactName__c = 'test';
        this.theContact.AddressLine1__c = 'test';
        this.theContact.AddressLine2__c = 'test';
        this.theContact.AddressLine3__c = 'test';
        this.theContact.City__c = 'test';
        this.theContact.State__c = 'test';
        this.theContact.ZipCode__c = '00000';
        this.theContact.CountryCode__c = 'USA';
        this.theContact.Salutation__c = 'President';
        this.theContact.ContactTitle__c = 'President';
        this.theContact.TelephoneNo1__c = '123-456-7890';
        this.theContact.TelephoneExt1__c = '123';
        this.theContact.TelephoneNo2__c = '098-765-4321';
        this.theContact.TelephoneExt2__c = '098';
        this.theContact.FaxNo__c = '123-456-7890';
        this.theContact.EmailAddress__c = 'test@email.com';
        
        if (doInsert == true){
            insert this.theContact;
        }
        return this.theContact;
    }

    public Fulfillment__c createFulfillment(Boolean doInsert, Account acct, String salesOrderNo){
        
        this.fulfillment = new Fulfillment__c(); // TODO: Map fields
        this.fulfillment.Name = 'test';
        this.fulfillment.ARDivisionNo__c = acct.ARDivisionNo__c;
        this.fulfillment.CustomerNo__c = acct.CustomerNo__c;
        this.fulfillment.SalespersonNo__c = '0012';
        this.fulfillment.Sales_Order_Number__c = salesOrderNo;
        this.fulfillment.ShipExpireDate__c = '2020-01-01 00:00:00.0000000';
        this.fulfillment.OrderDate__c = '2020-01-01 00:00:00.0000000';
        this.fulfillment.TaxableAmt__c = '100.00';
        this.fulfillment.NonTaxableAmt__c = '10.00';
        this.fulfillment.SalesTaxAmt__c = '10.00';
        this.fulfillment.FreightAmt__c = '3270';
        this.fulfillment.OrderType__c = 'S';
        this.fulfillment.OrderStatus__c = 'O';
        this.fulfillment.Warehouse__c = '010';
        this.fulfillment.Comments__c = 'test';
        this.fulfillment.UDF_DELIVERY_DATE__c = '2020-01-01';
        
        if (doInsert == true){
            insert this.fulfillment;
        }
        return this.fulfillment;
    }

    public Customer_Sales_History__c createCustomerSalesHistory(Boolean doInsert, Account acct, String fiscalYear, String fiscalPeriod){
        
        this.customerSalesHistory = new Customer_Sales_History__c(); // TODO: Map fields

        this.customerSalesHistory.External_Id__c = acct.ARDivisionNo__c + '-' + acct.CustomerNo__c + '-' + fiscalYear + '-' + fiscalPeriod;
        this.customerSalesHistory.Name = acct.ARDivisionNo__c + '-' + acct.CustomerNo__c + '-' + fiscalYear + '-' + fiscalPeriod;
        this.customerSalesHistory.ARDivisionNo__c = acct.ARDivisionNo__c;
        this.customerSalesHistory.CustomerNo__c = acct.CustomerNo__c;
        this.customerSalesHistory.FiscalYear__c = fiscalYear;
        this.customerSalesHistory.FiscalPeriod__c = fiscalPeriod;
        this.customerSalesHistory.Dollars_Sold__c = 100.00;
        this.customerSalesHistory.CostOfGoodsSold__c = '10.00';
        this.customerSalesHistory.CashReceived__c = '10.00';
        this.customerSalesHistory.FinanceCharges__c = '10.00';
        this.customerSalesHistory.NumberOfInvoices__c = '1';
        this.customerSalesHistory.NumberOfFinanceChrgs__c = '1';
        this.customerSalesHistory.DateUpdated__c = '2020-01-01 00:00:00.0000000';
        this.customerSalesHistory.TimeUpdated__c = '11.25963';
        this.customerSalesHistory.Customer__c = acct.Id;
        
        if (doInsert == true){
            insert this.customerSalesHistory;
        }
        return this.customerSalesHistory;
    }

    public Historical_Sales__c createHistoricalSales(Boolean doInsert, Account acct, String invoiceNo, String headerSeqNo){
        
        this.historicalSales = new Historical_Sales__c(); // TODO: Map fields

        this.historicalSales.External_Id__c = invoiceNo + '-' + headerSeqNo;
        this.historicalSales.ARDivisionNo__c = acct.ARDivisionNo__c;
        this.historicalSales.CustomerNo__c = acct.CustomerNo__c;
        this.historicalSales.InvoiceDate__c = '2020-01-01';
        this.historicalSales.Invoice_Number__c = invoiceNo;
        this.historicalSales.HeaderSeqNo__c = headerSeqNo;
        //this.historicalSales.TaxableSalesAmt__c = '30';
        //this.historicalSales.NonTaxableSalesAmt__c = '500';
        this.historicalSales.Name = invoiceNo;
        this.historicalSales.Customer_PO_Number__c = 'test';
        this.historicalSales.Freight_Amount__c = 17.25;
        this.historicalSales.InvoiceDueDate__c = '2020-01-01';
        this.historicalSales.Less_Freight_Discount__c = 0;
        this.historicalSales.OrderDate__c = '2020-01-01';
        this.historicalSales.Order_Number__c = 'NULL';
        this.historicalSales.Rep__c = '0012';
        this.historicalSales.Sales_Tax__c = 84.22;
        this.historicalSales.ShipDate__c = '2020-01-01';
        this.historicalSales.Ship_Via__c = 'CONWAY';
        this.historicalSales.TermsCode__c = '00';
        
        if (doInsert == true){
            insert this.historicalSales;
        }
        return this.historicalSales;
    }

    public Historical_Sale_Details__c createHistoricalSaleDetails(Boolean doInsert, Historical_Sales__c historicalSale, String detailSeqNo){
        
        this.historicalSaleDetails = new Historical_Sale_Details__c(); // TODO: Map fields

        this.historicalSaleDetails.Invoice_Order_Detail__c = historicalSale.Invoice_Number__c + '-' + historicalSale.HeaderSeqNo__c + '-' + detailSeqNo;
        this.historicalSaleDetails.Quantity_Ordered__c = 1;
        this.historicalSaleDetails.Quantity_Shipped__c = 1;
        this.historicalSaleDetails.Quantity_BackOrdered__c = 1;
        this.historicalSaleDetails.Item_Code__c = '/M';
        this.historicalSaleDetails.Item_Description__c = 'Freight for Invc test';
        this.historicalSaleDetails.Unit_Price__c = 1;
        this.historicalSaleDetails.Name = 'test';
        this.historicalSaleDetails.InvoiceNo__c = historicalSale.Invoice_Number__c;
        this.historicalSaleDetails.HeaderSeqNo__c = historicalSale.HeaderSeqNo__c;
        this.historicalSaleDetails.DetailSeqNo__c = detailSeqNo;
        
        if (doInsert == true){
            insert this.historicalSaleDetails;
        }
        return this.historicalSaleDetails;
    }

    public Open_Invoice__c createOpenInvoice(Boolean doInsert, Account acct, String invoiceNo, String invoiceHistoryHeaderSeqNo){
        
        this.openInvoice = new Open_Invoice__c(); // TODO: Map fields

        this.openInvoice.ARDivisionNo__c = acct.ARDivisionNo__c;
        this.openInvoice.SageCustomerNo__c = acct.CustomerNo__c;
        this.openInvoice.InvoiceDate__c = '2020-01-01 00:00:00.0000000';
        this.openInvoice.Invoice_Number__c = invoiceNo + '-' + 'IN';
        this.openInvoice.Balance__c = 4785.06;
        this.openInvoice.DueDate__c = '2020-01-01 00:00:00.0000000';
        this.openInvoice.DiscountDate__c = '2020-01-01';
        this.openInvoice.Discount_Amount__c = 16.45;
        this.openInvoice.Name = invoiceNo + '-' + 'IN';
        this.openInvoice.Freight_Amount__c = 1495;
        this.openInvoice.Sales_Tax__c = 336;
        this.openInvoice.Customer_PO_Number__c = 'test';
        this.openInvoice.TermsCode__c = '99';
        this.openInvoice.Rep__c = '0012';
        this.openInvoice.External_Id__c = acct.ARDivisionNo__c + '-' + acct.CustomerNo__c + '-' + invoiceNo + '-' + invoiceHistoryHeaderSeqNo;
        
        if (doInsert == true){
            insert this.openInvoice;
        }
        return this.openInvoice;
    }

    public DailyShipment__c createDailyShipment(Boolean doInsert, Account acct, String invoiceNo){
        
        this.dailyShipment = new DailyShipment__c(); // TODO: Map fields

        this.dailyShipment.InvoiceNo__c = invoiceNo;
        this.dailyShipment.Account__c = acct.Id;
        this.dailyShipment.ARDivisionNo__c = acct.ARDivisionNo__c;
        this.dailyShipment.CustomerNo__c = acct.CustomerNo__c;
        this.dailyShipment.SalesOrderNo__c = '46379';
        this.dailyShipment.ShipDate__c = '2007-05-21 00:00:00.0000000';
        this.dailyShipment.ShipVia__c = 'USF REDDAWAY';
        this.dailyShipment.ShipperID__c = 'DP';
        this.dailyShipment.FreightAmt__c = '0.0000000000';
        this.dailyShipment.InvoiceTotal__c = '1094.9800000000';
        this.dailyShipment.DateUpdated__c = '2007-05-21 00:00:00.0000000';
        this.dailyShipment.TimeUpdated__c = '8.0252000000';
        this.dailyShipment.UserUpdatedKey__c = '26';
        
        if (doInsert == true){
            insert this.dailyShipment;
        }
        return this.dailyShipment;
    }
}