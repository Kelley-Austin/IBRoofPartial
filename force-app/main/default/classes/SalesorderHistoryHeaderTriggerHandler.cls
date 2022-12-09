/**
 * Name         :   SalesorderHistoryHeaderTriggerHandler
 * Developer    :   Kelley Austin
 * Created On   :   02/16/2022
 * Description  :   Handler class for SAG100SalesorderHistoryHeaderTrigger. contains method for after insert, after update and before delete
 *                  Roll up CY_Historical_Sales_2__c and PY_Historical_Sales_2__c on Account when Salesorder inserted, updated or deleted
 *                  Map SALESORDERHISTORYHEADER ORDERSTATUS to SO_SALESORDERHEADER__c Related_History_Header_Orderstatus when ORDERSTATUS is changed or SALESORDERHISTORYHEADER is created
 * Test class   :   SalesorderHistoryHeaderTriggerTest
 */
public class SalesorderHistoryHeaderTriggerHandler{
    /*
    // Method to handle after insert logic for SAGE100_SALESORDERHISTORYHEADER
    public static void afterInsert(List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> newList) {
        system.debug('#### afterInsert : '+newList);
        Set<Id> accountIds = new Set<Id>();
        Set<String> customerIds = new Set<String>();
        Set<String> monthSet = new Set<String>();
        Set<String> yearSet = new Set<String>();
        Set<String> externalKeySet = new Set<String>();
        
        for(CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder : newList){
            // Check if account is not null on new SALESORDERHISTORYHEADER
            if(salesOrder.CommercientSF8__Account__c != null){
                accountIds.add(salesOrder.CommercientSF8__Account__c);
            }

            // Check if customer is not null on new SALESORDERHISTORYHEADER
            if(salesOrder.CommercientSF8__CUSTOMERNO__c != null && salesOrder.CommercientSF8__LASTINVOICEDATE__c != null){
                customerIds.add(salesOrder.CommercientSF8__CUSTOMERNO__c);
                monthSet.add(salesOrder.Invoice_Month__c);
                yearSet.add(salesOrder.Invoice_Year__c);
                externalKeySet.add(salesOrder.CommercientSF8__ARDIVISIONNO__c+'-'+salesOrder.CommercientSF8__CUSTOMERNO__c+'-'+salesOrder.Invoice_Year__c+'-'+salesOrder.Invoice_Month__c);
            }
        }
        // Invoke rollupCYPYTotals method if there are valid records to process
        if(!accountIds.isEmpty()){
            SalesorderHistoryHeaderTriggerHandler.rollupCYPYTotals(accountIds, null);
        }

        // Invoke rollupDollarsSoldOnCustomerHistory method if there are valid records to process
        if(!customerIds.isEmpty()){
            SalesorderHistoryHeaderTriggerHandler.rollupDollarsSoldOnCustomerHistory(customerIds, monthSet, yearSet, externalKeySet);
        }
    }

    // Method to handle after update logic for SAGE100_SALESORDERHISTORYHEADER.
    public static void afterUpdate(List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> newList, map<Id,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<String> customerIds = new Set<String>();
        Set<String> monthSet = new Set<String>();
        Set<String> yearSet = new Set<String>();
        Set<String> externalKeySet = new Set<String>();
        for(CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder : newList){
            // Check if account is changed on updated SALESORDERHISTORYHEADER record
            if(salesOrder.CommercientSF8__Account__c != oldMap.get(salesOrder.Id).CommercientSF8__Account__c){
                // If new account is not null, we need to rollup values for new account
                if(salesOrder.CommercientSF8__Account__c != null){
                    accountIds.add(salesOrder.CommercientSF8__Account__c);
                }
                // If prior account is not null, we need to rollup values for prior account
                if(oldMap.get(salesOrder.Id).CommercientSF8__Account__c != null){
                    accountIds.add(oldMap.get(salesOrder.Id).CommercientSF8__Account__c);
                }
            }
            // Check if Invoice_Total or LASTINVOICEDATE is changed on SALESORDERHISTORYHEADER record
            if(salesOrder.Invoice_Total__c != oldMap.get(salesOrder.Id).Invoice_Total__c || salesOrder.CommercientSF8__LASTINVOICEDATE__c != oldMap.get(salesOrder.Id).CommercientSF8__LASTINVOICEDATE__c){
                accountIds.add(salesOrder.CommercientSF8__Account__c);
            }

            // Check if Dollars_Sold or LASTINVOICEDATE is changed on SALESORDERHISTORYHEADER record
            if(salesOrder.Dollars_Sold__c != oldMap.get(salesOrder.Id).Dollars_Sold__c || salesOrder.CommercientSF8__LASTINVOICEDATE__c != oldMap.get(salesOrder.Id).CommercientSF8__LASTINVOICEDATE__c){
                customerIds.add(salesOrder.CommercientSF8__CUSTOMERNO__c);
                monthSet.add(salesOrder.Invoice_Month__c);
                yearSet.add(salesOrder.Invoice_Year__c);
                externalKeySet.add(salesOrder.CommercientSF8__ARDIVISIONNO__c+'-'+salesOrder.CommercientSF8__CUSTOMERNO__c+'-'+salesOrder.Invoice_Year__c+'-'+salesOrder.Invoice_Month__c);
                if(salesOrder.CommercientSF8__LASTINVOICEDATE__c != oldMap.get(salesOrder.Id).CommercientSF8__LASTINVOICEDATE__c){
                    monthSet.add(oldMap.get(salesOrder.Id).Invoice_Month__c);
                    yearSet.add(oldMap.get(salesOrder.Id).Invoice_Year__c);
                    externalKeySet.add(salesOrder.CommercientSF8__ARDIVISIONNO__c+'-'+salesOrder.CommercientSF8__CUSTOMERNO__c+'-'+oldMap.get(salesOrder.Id).Invoice_Year__c+'-'+oldMap.get(salesOrder.Id).Invoice_Month__c);
                }
            }
        }
        // Invoke rollupCYPYTotals method if there are valid records to process
        if(!accountIds.isEmpty()){
            SalesorderHistoryHeaderTriggerHandler.rollupCYPYTotals(accountIds, null);
        }

        // Invoke rollupDollarsSoldOnCustomerHistory method if there are valid records to process
        if(!customerIds.isEmpty()){
            SalesorderHistoryHeaderTriggerHandler.rollupDollarsSoldOnCustomerHistory(customerIds, monthSet, yearSet, externalKeySet);
        }
    }

    // Method to handle before delete logic for SAGE100_SALESORDERHISTORYHEADER.
    public static void beforeDelete(map<Id,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> oldMap) {
        Set<Id> salesOrderIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder : oldMap.values()){
            // Check if account was not null on deleted SALESORDERHISTORYHEADER
            if(salesOrder.CommercientSF8__Account__c != null){
                salesOrderIds.add(salesOrder.Id);
                accountIds.add(salesOrder.CommercientSF8__Account__c);
            }
        }
        // Invoke rollupCYPYTotals method if there are valid records to process
        if(!accountIds.isEmpty()){
            SalesorderHistoryHeaderTriggerHandler.rollupCYPYTotals(accountIds,salesOrderIds);
        }
    }

    // Method to rollup PY_Historical_Sales_2 and CY_Historical_Sales_2 fields on account with sum of Invoice Total on SALESORDERHISTORYHEADER
    public static void rollupCYPYTotals(Set<Id> accountIds, Set<Id> salesOrderIds){
        Map<Id,Account> accToUpdate = new Map<Id,Account>();
        String currentYear = String.valueOf(System.today().year());
        String previousYear = String.valueOf(System.today().year()-1);

        AggregateResult[] cyGroupedResults;
        AggregateResult[] pyGroupedResults;
        if(salesOrderIds == null || salesOrderIds.isEmpty()){
            // This will only execute for delete trigger. Fetch sum of Invoice_Total from all current year SALESORDERHISTORYHEADER records except deleted record group by account
            cyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Invoice_Total__c) 
                                FROM CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: currentYear
                                GROUP BY CommercientSF8__Account__c];
            // This will only execute for delete trigger. Fetch sum of Invoice_Total from all previous year SALESORDERHISTORYHEADER records except deleted record group by account
            pyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Invoice_Total__c) 
                                FROM CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: previousYear
                                GROUP BY CommercientSF8__Account__c];
        }else{
            // This will only execute for insert and update trigger. Fetch sum of Invoice_Total from all current year SALESORDERHISTORYHEADER record group by account
            cyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Invoice_Total__c) 
                                FROM CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: currentYear AND Id Not IN : salesOrderIds
                                GROUP BY CommercientSF8__Account__c];
            // This will only execute for insert and update trigger. Fetch sum of Invoice_Total from all previous year SALESORDERHISTORYHEADER record group by account
            pyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Invoice_Total__c) 
                                FROM CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: previousYear AND Id Not IN : salesOrderIds
                                GROUP BY CommercientSF8__Account__c];
        }
        
        // Iterate over aggregate result for current year and create instances of account records to be updated
        for (AggregateResult ar : cyGroupedResults)  {
            System.debug('Account ID' + ar.get('CommercientSF8__Account__c'));
            System.debug('Sum amount' + ar.get('expr0'));
            Account acc = new Account(Id = (Id)ar.get('CommercientSF8__Account__c'));
            acc.CY_Historical_Sales_2__c = (Decimal)ar.get('expr0');
            acc.PY_Historical_Sales_2__c = 0;
            accToUpdate.put((Id)ar.get('CommercientSF8__Account__c'),acc);
        }

        // Iterate over aggregate result for previous year and create instances of account records to be updated
        for (AggregateResult ar : pyGroupedResults)  {
            System.debug('Account ID' + ar.get('CommercientSF8__Account__c'));
            System.debug('Sum amount' + ar.get('expr0'));
            Account acc = accToUpdate.get((Id)ar.get('CommercientSF8__Account__c'));
            if(acc == null){
                // Create new instance if account not found for current year aggregate result
                acc = new Account(Id = (Id)ar.get('CommercientSF8__Account__c'), CY_Historical_Sales_2__c = 0);
            }
            acc.PY_Historical_Sales_2__c = (Decimal)ar.get('expr0');
            accToUpdate.put((Id)ar.get('CommercientSF8__Account__c'),acc);
        }

        // Reset PY_Historical_Sales_2 and CY_Historical_Sales_2 to 0 if no SALESORDERHISTORYHEADER records found for an account
        for(Id accId : accountIds){
            if(!accToUpdate.containsKey(accId)){
                accToUpdate.put(accId,new Account(Id = accId, PY_Historical_Sales_2__c = 0, CY_Historical_Sales_2__c = 0));
            }
        }

        // Update account records
        if(!accToUpdate.isEmpty()){
            update accToUpdate.values();
        }
    }

    // Method to rollup Dollars_Sold on Customer_Sales_History with sum of Dollars_Sold on SALESORDERHISTORYHEADER
    public static void rollupDollarsSoldOnCustomerHistory(Set<String> customerIds, Set<String> monthSet, Set<String> yearSet, Set<String> externalKeySet){
        Map<String,Decimal> customerDollarsMap = new Map<String,Decimal>();
        Map<String,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> customerSalesOrderMap = new Map<String,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c>();
        // Fetch all related SalesOrder for the customer
        for(CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder : [SELECT Id, CommercientSF8__Customer__c, CommercientSF8__CUSTOMERNO__c, CommercientSF8__ARDIVISIONNO__c, Invoice_Year__c, 
                                                                            Invoice_Month__c, Dollars_Sold__c FROM CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c 
                                                                            WHERE CommercientSF8__CUSTOMERNO__c =: customerIds AND Invoice_Month__c IN : monthSet AND Invoice_Year__c IN : yearSet]){

            // Generate external Id for Customer Sales History and rollup Dollars_Sold__c grouped by external id
            String externalId = salesOrder.CommercientSF8__ARDIVISIONNO__c+'-'+salesOrder.CommercientSF8__CUSTOMERNO__c+'-'+salesOrder.Invoice_Year__c+'-'+salesOrder.Invoice_Month__c;
            decimal dollarSum = customerDollarsMap.get(externalId);
            if(dollarSum == null){
                dollarSum = 0;
            }
            dollarSum += salesOrder.Dollars_Sold__c;
            // Map of key to dollar sold total.
            customerDollarsMap.put(externalId,dollarSum);
            // Map of key to salesorder. All salesorder with same key will have same values. so doesn't matter if override with each other.
            customerSalesOrderMap.put(externalId,salesOrder);
        }

        // Fetch existing Customer_Sales_History based on the external key generated above
        Map<String,Customer_Sales_History__c> customerSalesHistoryMap = new Map<String,Customer_Sales_History__c>();
        for(Customer_Sales_History__c csh : [SELECT Id, Name, Dollars_Sold__c, Customer__c, CustomerNo__c, External_Id__c, ARDivisionNo__c, FiscalYear__c, FiscalPeriod__c FROM Customer_Sales_History__c WHERE External_Id__c IN : externalKeySet]){
            customerSalesHistoryMap.put(csh.External_Id__c,csh);
        }

        List<Customer_Sales_History__c> customerSalesHistoryToUpsert = new List<Customer_Sales_History__c>();
        for(String externalId : externalKeySet){
            system.debug('#### externalId : '+externalId);
            Customer_Sales_History__c csh = customerSalesHistoryMap.get(externalId);
            CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder = customerSalesOrderMap.get(externalId);
            if(csh == null && customerSalesOrderMap.containsKey(externalId)){
                // If Customer_Sales_History doesn't exist, create a new instance
                csh = new Customer_Sales_History__c();
                csh.ARDivisionNo__c = salesOrder.CommercientSF8__ARDIVISIONNO__c;
                csh.CustomerNo__c = salesOrder.CommercientSF8__CUSTOMERNO__c;
                csh.FiscalYear__c = salesOrder.Invoice_Year__c;
                csh.FiscalPeriod__c = salesOrder.Invoice_Month__c;
                csh.External_Id__c = externalId;
                csh.Name = externalId;
            }
            if(customerDollarsMap.containsKey(externalId)){
                csh.Dollars_Sold__c = customerDollarsMap.get(externalId);
            }else{
                csh.Dollars_Sold__c = 0;
            }
            customerSalesHistoryToUpsert.add(csh);
        }
        system.debug('#### customerSalesHistoryToUpsert : '+customerSalesHistoryToUpsert);
        upsert customerSalesHistoryToUpsert External_Id__c;
    }
    */

    /** Map SALESORDERHISTORYHEADER ORDERSTATUS to SO_SALESORDERHEADER__c Related_History_Header_Orderstatus when ORDERSTATUS is changed or SALESORDERHISTORYHEADER is created */
    public static void mapStatusOnOpenSalesOrders (List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> newList, map<Id,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> oldMap){
        System.debug('#### mapStatusOnOpenSalesOrders called : '+newList);
        /** Iterate over SALESORDERHISTORYHEADER and if SALESORDERHISTORYHEADER ORDERSTATUS is not null and ORDERSTATUS or Trigger_Orderstatus_Mapping changed, create a map of SALESORDERHISTORYHEADER name and SALESORDERHISTORYHEADER */
        Map<String,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> salesOrderHistoryHeaderMap = new Map<String,CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c>();
        for(CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesHeader : newList){
            if(salesHeader.CommercientSF8__ORDERSTATUS__c != null && (oldMap == null || salesHeader.CommercientSF8__ORDERSTATUS__c != oldMap.get(salesHeader.Id).CommercientSF8__ORDERSTATUS__c || salesHeader.Trigger_Orderstatus_Mapping__c != oldMap.get(salesHeader.Id).Trigger_Orderstatus_Mapping__c)){
                salesOrderHistoryHeaderMap.put(salesHeader.Name,salesHeader);
            }
        }
        System.debug('#### salesOrderHistoryHeaderMap : '+salesOrderHistoryHeaderMap);
        
        if(salesOrderHistoryHeaderMap.size() > 0){
            /** Fetch SO_SALESORDERHEADER with same name as SALESORDERHISTORYHEADER and create a map of SO_SALESORDERHEADER name and SALESORDERHISTORYHEADER */
            Map<String,List<CommercientSF8__SO_SALESORDERHEADER__c>> openSalesOrderMap = new Map<String,List<CommercientSF8__SO_SALESORDERHEADER__c>>();
            for(CommercientSF8__SO_SALESORDERHEADER__c openSalesOrder : [SELECT Id, Name, Related_History_Header_Orderstatus__c FROM CommercientSF8__SO_SALESORDERHEADER__c WHERE Name IN : salesOrderHistoryHeaderMap.keyset()]){
                List<CommercientSF8__SO_SALESORDERHEADER__c> temp = openSalesOrderMap.get(openSalesOrder.Name);
                if(temp == null){
                    temp = new List<CommercientSF8__SO_SALESORDERHEADER__c>();
                }
                temp.add(openSalesOrder);
                openSalesOrderMap.put(openSalesOrder.Name,temp);
            }
            System.debug('#### openSalesOrderMap : '+openSalesOrderMap);
            List<CommercientSF8__SO_SALESORDERHEADER__c> openSalesOrderToUpdate = new List<CommercientSF8__SO_SALESORDERHEADER__c>();
            /** If there is a SO_SALESORDERHEADER matching with SALESORDERHISTORYHEADER, copy ORDERSTATUS to Related_History_Header_Orderstatus */
            for(String orderName : salesOrderHistoryHeaderMap.keyset()){
                if(openSalesOrderMap.containsKey(orderName) && openSalesOrderMap.get(orderName).size() == 1){
                    CommercientSF8__SO_SALESORDERHEADER__c openSalesOrder = openSalesOrderMap.get(orderName)[0];
                    openSalesOrderToUpdate.add(new CommercientSF8__SO_SALESORDERHEADER__c(Id = openSalesOrder.Id, Related_History_Header_Orderstatus__c = salesOrderHistoryHeaderMap.get(orderName).CommercientSF8__ORDERSTATUS__c));
                }
            }

            System.debug('#### openSalesOrderToUpdate : '+openSalesOrderToUpdate);
            if(!openSalesOrderToUpdate.isEmpty()){
                update openSalesOrderToUpdate;
            }
        }
    }
}