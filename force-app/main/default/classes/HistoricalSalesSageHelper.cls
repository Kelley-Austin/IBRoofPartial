public class HistoricalSalesSageHelper {
    private List<Historical_Sales__c> oldList;
    private List<Historical_Sales__c> newList;
    
    public HistoricalSalesSageHelper(List<Historical_Sales__c> oldList, List<Historical_Sales__c> newList) {
    	this.oldList = (oldList == null) ? new List<Historical_Sales__c>() : oldList;
    	this.newList = (newList == null) ? new List<Historical_Sales__c>() : newList;
    }

    public void execute() {
        Set<String> customerIds = new Set<String>();
        Set<String> termscodeIds = new Set<String>();
        
        Map<String,Terms_Code__c> termsMap = new Map<String,Terms_Code__c>();
        
        for (Historical_Sales__c hs : this.newList) {
            termscodeIds.add(hs.TermsCode__c);
        }
        
        List<Terms_Code__c> termsCodeList = [SELECT Id, TermsCode__c, TermsCodeDesc__c 
                                            FROM Terms_Code__c 
                                            WHERE TermsCode__c IN : termscodeIds 
                                            AND TermsCode__c != null];
        
        for (Terms_Code__c tc : termsCodeList){
            termsMap.put(tc.TermsCode__c,tc);
        }
        
        for (Historical_Sales__c hs : this.newList) {
            if (termsMap.containsKey(hs.TermsCode__c) == false)
                continue;
            hs.Terms_Code__c = termsMap.get(hs.TermsCode__c).Id;
            hs.Terms__c = termsMap.get(hs.TermsCode__c).TermsCodeDesc__c;
        }

        for (Historical_Sales__c historicalSale : this.newList) {
            
            
            
            if (String.isBlank(historicalSale.ARDivisionNo__c))
                continue;

            if (String.isBlank(historicalSale.CustomerNo__c))
                continue;

            customerIds.add(historicalSale.ARDivisionNo__c + '-' + historicalSale.CustomerNo__c);
        }
        
        //Dates and Decimals
        for (Historical_Sales__c hs : this.newList) {
            
            hs.Invoice_Due_Date__c = SageUtility.parseDate(hs.InvoiceDueDate__c);
            hs.Order_Date__c = SageUtility.parseDate(hs.OrderDate__c);
            hs.Ship_Date__c = SageUtility.parseDate(hs.ShipDate__c);
            hs.Invoice_Date__c = SageUtility.parseDate(hs.InvoiceDate__c);
            
            hs.Taxable_Total__c = this.calculateTaxableTotal(hs.TaxableSalesAmt__c,
                                                             hs.NonTaxableSalesAmt__c,
                                                             hs.Less_Freight_Discount__c,
                                                             hs.Freight_Amount__c);
			
            hs.Invoice_Total__c = this.calculateInvoiceTotal(hs.TaxableSalesAmt__c,
                                                             hs.NonTaxableSalesAmt__c,
                                                             hs.Less_Freight_Discount__c,
                                                             hs.Freight_Amount__c,
                                                             hs.Sales_Tax__c);
            
        }

        List<Account> customers = [SELECT Id, External_Id__c FROM Account WHERE External_Id__c IN :customerIds];
        Map<String,Account> customerByExtId = new Map<String,Account>();

        for (Account customer : customers) {
            customerByExtId.put(customer.External_Id__c, customer);
        }

        for (Historical_Sales__c historicalSale : this.newList) {
            if (String.isBlank(historicalSale.ARDivisionNo__c))
                continue;

            if (String.isBlank(historicalSale.CustomerNo__c))
                continue;

            Account customer = customerByExtId.get(historicalSale.ARDivisionNo__c + '-' + historicalSale.CustomerNo__c);

            if (customer == null)
                continue;

            if (historicalSale.Customer_Account__c == customer.Id)
                continue;

            historicalSale.Customer_Account__c = customer.Id;
        }
    }
    
    @testVisible
    private Decimal calculateTaxableTotal(Decimal taxableSalesAmt, Decimal nonTaxableSalesAmt, Decimal lessFreightDiscount, Decimal freightAmount){
        
        taxableSalesAmt = (taxableSalesAmt == null)? 0 : taxableSalesAmt;
        
        nonTaxableSalesAmt = (nonTaxableSalesAmt == null)? 0 : nonTaxableSalesAmt;
        
        lessFreightDiscount = (lessFreightDiscount == null)? 0 : lessFreightDiscount;
        
        freightAmount = (freightAmount == null)? 0 : freightAmount;
        
        return taxableSalesAmt + nonTaxableSalesAmt + lessFreightDiscount + freightAmount;

    } 
    
    @testVisible
    private Decimal calculateInvoiceTotal(Decimal taxableSalesAmt, Decimal nonTaxableSalesAmt, Decimal lessFreightDiscount, Decimal freightAmount, Decimal salesTax){
        
        taxableSalesAmt = (taxableSalesAmt == null)? 0 : taxableSalesAmt;
        
        nonTaxableSalesAmt = (nonTaxableSalesAmt == null)? 0 : nonTaxableSalesAmt;
        
        lessFreightDiscount = (lessFreightDiscount == null)? 0 : lessFreightDiscount;
        
        freightAmount = (freightAmount == null)? 0 : freightAmount;
        
        salesTax = (salesTax == null)? 0 : salesTax;
        
        return taxableSalesAmt + nonTaxableSalesAmt + lessFreightDiscount + freightAmount;

    } 
}