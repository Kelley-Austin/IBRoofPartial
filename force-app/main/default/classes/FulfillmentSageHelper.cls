public class FulfillmentSageHelper {
    private List<Fulfillment__c> oldList;
    private List<Fulfillment__c> newList;
    
    public FulfillmentSageHelper(List<Fulfillment__c> oldList, List<Fulfillment__c> newList) {
    	this.oldList = (oldList == null) ? new List<Fulfillment__c>() : oldList;
    	this.newList = (newList == null) ? new List<Fulfillment__c>() : newList;
    }

    public void execute() {
        Set<String> customerIds = new Set<String>();
        Set<String> warehouseCodes = new Set<String>();

        // set warehouse relation
        for (Fulfillment__c ful : this.newList) {
            if (String.isBlank(ful.Warehouse__c) || ful.Warehouse__c == 'None')
                continue;

            warehouseCodes.add(ful.Warehouse__c);
        }

        List<Warehouse__c> warehouses = [SELECT Id, WarehouseCode__c FROM Warehouse__c WHERE WarehouseCode__c IN :warehouseCodes];
        Map<String,Warehouse__c> warehouseByExtIdMap = new Map<String,Warehouse__c>();

        for (Warehouse__c warehouse : warehouses) {
            warehouseByExtIdMap.put(warehouse.WarehouseCode__c, warehouse);
        }

        for (Fulfillment__c ful : this.newList) {
            if (String.isBlank(ful.Warehouse__c) || ful.Warehouse__c == 'None')
                continue;

            Warehouse__c warehouse = warehouseByExtIdMap.get(ful.Warehouse__c);

            if (warehouse == null)
                continue;

            ful.Warehouse_Lookup__c = warehouse.Id;
        }
        
        // set type, stage
        for (Fulfillment__c ful : this.newList) {
            ful.Type__c = parseType(ful.OrderType__c);
            ful.Status__c = parseStatus(ful.OrderStatus__c);
        }
        
        // set order amount
        for (Fulfillment__c ful : this.newList) {

            Decimal salesTaxAmt = parseDecimal(ful.SalesTaxAmt__c);
            Decimal nonTaxableAmt = parseDecimal(ful.NonTaxableAmt__c);
            Decimal taxableAmt = parseDecimal(ful.TaxableAmt__c);
            ful.Order_Total__c = taxableAmt + salesTaxAmt + nonTaxableAmt;                     

        }
        
        // set dates
        for (Fulfillment__c ful : this.newList) {
            ful.Order_Date__c = parseDate(ful.OrderDate__c);
            ful.Ship_Date__c = parseDate(ful.ShipExpireDate__c);
            ful.Ship_Date__c = maxDateParser(ful.Ship_Date__c);
            ful.Delivery_Date__c = parseDate(ful.Udf_Delivery_Date__c);
        }

        for (Fulfillment__c fulfillment : this.newList) {
            if (String.isBlank(fulfillment.ARDivisionNo__c))
                continue;

            if (String.isBlank(fulfillment.CustomerNo__c))
                continue;

            customerIds.add(fulfillment.ARDivisionNo__c + '-' + fulfillment.CustomerNo__c);
        }

        List<Account> customers = [SELECT Id, External_Id__c FROM Account WHERE External_Id__c IN :customerIds];
        Map<String,Account> customerByExtId = new Map<String,Account>();

        for (Account customer : customers) {
            customerByExtId.put(customer.External_Id__c, customer);
        }

        for (Fulfillment__c fulfillment : this.newList) {
            if (String.isBlank(fulfillment.ARDivisionNo__c))
                continue;

            if (String.isBlank(fulfillment.CustomerNo__c))
                continue;

            Account customer = customerByExtId.get(fulfillment.ARDivisionNo__c + '-' + fulfillment.CustomerNo__c);

            if (customer == null)
                continue;

            if (fulfillment.Customer__c == customer.Id)
                continue;

            fulfillment.Customer__c = customer.Id;
        }
    }
    @testVisible
    private static Decimal parseDecimal(String decimalString){
        Decimal parcedDecimal = 0;
        if (decimalString == null){
            return parcedDecimal;
        }
        try {
           parcedDecimal = Decimal.valueOf(decimalString);
        } catch (Exception e){
            system.debug(e.getMessage());
        }
        return parcedDecimal;
    }
    @testVisible
    private static Date parseDate(String dateString){
        Date parsedDate;
        if (dateString == null){
            return parsedDate;
        }
        try {
			parsedDate = Date.valueOf(dateString);
        } catch (exception e){
            system.debug(e.getMessage());
        }
        return parsedDate;
    }
    @testVisible
    private static Date maxDateParser(Date theDate) {
        Date maximumDate = Date.newInstance(4000, 12, 31);

        if (theDate == null)
            return null;

        if (theDate > maximumDate)
            return null;

        return theDate;
    }

    @testVisible
    private static String parseStatus(String orderStatus){
        switch on orderStatus {
            when 'N' {
                return 'New';
            } when 'O' {
                return 'Open';
            } when 'C' {
                return 'Completed';
            } when 'H' {
                return 'On Hold';
            } when 'Z' {
                return 'Deleted';
            } when else {
                return orderStatus;
            }
        }
    }
    @testVisible
    private static String parseType(String orderType){
        
        switch on orderType {
            when 'S' {
                return 'Standard';
            } when 'B' {
                return 'Backorder';
            } when 'M' {
                return 'Master';
            } when 'R' {
                return 'Repeating';
            } when 'Q' {
                return 'Quote';
            } when 'P' {
                return 'Prospect Quote';
            } when else {
                return orderType;
            }
        }
    }
}