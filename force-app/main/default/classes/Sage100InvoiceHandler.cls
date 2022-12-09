/**
 * Name         :   Sage100InvoiceHandler
 * Developer    :   Kelley Austin
 * Created On   :   03/16/2022
 * Description  :   Handler class for Sage100InvoiceTrigger. contains method for after insert, after update and before delete
 *                  Roll up CY_Historical_Sales_2__c and PY_Historical_Sales_2__c on Account when Invoice inserted, updated or deleted
 * Test class   :   
 */
public class Sage100InvoiceHandler{
    // Method to handle after insert logic for SAGE100_Sage100InvoiceHandler
    public static void afterInsert(List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> newList) {
        system.debug('#### afterInsert : '+newList);
        Set<Id> accountIds = new Set<Id>();
        Set<String> customerIds = new Set<String>();
        Set<String> monthSet = new Set<String>();
        Set<String> yearSet = new Set<String>();
        Set<String> externalKeySet = new Set<String>();
        
        for(CommercientSF8__AR_INVOICEHISTORYHEADER__c Invoice : newList){
            // Check if account is not null on new Sage100InvoiceHandler
            if(Invoice.CommercientSF8__Account__c != null && Invoice.CommercientSF8__INVOICEDATE__c != null){
                accountIds.add(Invoice.CommercientSF8__Account__c);
            }

            // Check if customer is not null on new Sage100InvoiceHandler
            if(Invoice.CommercientSF8__CUSTOMERNO__c != null && Invoice.CommercientSF8__ARDIVISIONNO__c != null && Invoice.CommercientSF8__INVOICEDATE__c != null){
                customerIds.add(Invoice.CommercientSF8__CUSTOMERNO__c);
                monthSet.add(Invoice.Invoice_Month__c);
                yearSet.add(Invoice.Invoice_Year__c);
                externalKeySet.add(Invoice.CommercientSF8__ARDIVISIONNO__c+'-'+Invoice.CommercientSF8__CUSTOMERNO__c+'-'+Invoice.Invoice_Year__c+'-'+Invoice.Invoice_Month__c);
            }
        }
        // Invoke rollupCYPYTotals method if there are valid records to process
        system.debug('#### accountIds : '+accountIds);
        if(!accountIds.isEmpty()){
            Sage100InvoiceHandler.rollupCYPYTotals(accountIds, null);
        }

        // Invoke rollupDollarsSoldOnCustomerHistory method if there are valid records to process
        system.debug('#### customerIds : '+customerIds);
        if(!customerIds.isEmpty()){
            Sage100InvoiceHandler.rollupDollarsSoldOnCustomerHistory(customerIds, monthSet, yearSet, externalKeySet);
        }
    }

    // Method to handle after update logic for Sage100InvoiceHandler.
    public static void afterUpdate(List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> newList, map<Id,CommercientSF8__AR_INVOICEHISTORYHEADER__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<String> customerIds = new Set<String>();
        Set<String> monthSet = new Set<String>();
        Set<String> yearSet = new Set<String>();
        Set<String> externalKeySet = new Set<String>();
        for(CommercientSF8__AR_INVOICEHISTORYHEADER__c Invoice : newList){
            // Check if account is changed on updated Sage100InvoiceHandler record
            if(Invoice.CommercientSF8__Account__c != oldMap.get(Invoice.Id).CommercientSF8__Account__c){
                // If new account is not null, we need to rollup values for new account
                if(Invoice.CommercientSF8__Account__c != null){
                    accountIds.add(Invoice.CommercientSF8__Account__c);
                }
                // If prior account is not null, we need to rollup values for prior account
                if(oldMap.get(Invoice.Id).CommercientSF8__Account__c != null){
                    accountIds.add(oldMap.get(Invoice.Id).CommercientSF8__Account__c);
                }
            }
            // Check if Invoice_Total or LASTINVOICEDATE is changed on Sage100InvoiceHandler record
            if(Invoice.Dollars_Sold__c != oldMap.get(Invoice.Id).Dollars_Sold__c|| Invoice.Recalculate_Rollups__c != oldMap.get(Invoice.Id).Recalculate_Rollups__c || Invoice.CommercientSF8__INVOICEDATE__c != oldMap.get(Invoice.Id).CommercientSF8__INVOICEDATE__c){
                if(Invoice.CommercientSF8__INVOICEDATE__c != null || oldMap.get(Invoice.Id).CommercientSF8__INVOICEDATE__c != null){
                    accountIds.add(Invoice.CommercientSF8__Account__c);
                }
            }

            // Check if Dollars_Sold or LASTINVOICEDATE is changed on Sage100InvoiceHandler record
            if(Invoice.CommercientSF8__CUSTOMERNO__c != null && Invoice.CommercientSF8__ARDIVISIONNO__c != null && (Invoice.Dollars_Sold__c != oldMap.get(Invoice.Id).Dollars_Sold__c || Invoice.CommercientSF8__INVOICEDATE__c != oldMap.get(Invoice.Id).CommercientSF8__INVOICEDATE__c) || Invoice.Recalculate_Rollups__c != oldMap.get(Invoice.Id).Recalculate_Rollups__c){
                if(Invoice.CommercientSF8__INVOICEDATE__c != null){
                    customerIds.add(Invoice.CommercientSF8__CUSTOMERNO__c);
                    monthSet.add(Invoice.Invoice_Month__c);
                    yearSet.add(Invoice.Invoice_Year__c);
                    externalKeySet.add(Invoice.CommercientSF8__ARDIVISIONNO__c+'-'+Invoice.CommercientSF8__CUSTOMERNO__c+'-'+Invoice.Invoice_Year__c+'-'+Invoice.Invoice_Month__c);
                }
                if(Invoice.CommercientSF8__INVOICEDATE__c != oldMap.get(Invoice.Id).CommercientSF8__INVOICEDATE__c && oldMap.get(Invoice.Id).CommercientSF8__INVOICEDATE__c != null){
                    monthSet.add(oldMap.get(Invoice.Id).Invoice_Month__c);
                    yearSet.add(oldMap.get(Invoice.Id).Invoice_Year__c);
                    externalKeySet.add(Invoice.CommercientSF8__ARDIVISIONNO__c+'-'+Invoice.CommercientSF8__CUSTOMERNO__c+'-'+oldMap.get(Invoice.Id).Invoice_Year__c+'-'+oldMap.get(Invoice.Id).Invoice_Month__c);
                }
            }
        }
        // Invoke rollupCYPYTotals method if there are valid records to process
        system.debug('#### accountIds : '+accountIds);
        if(!accountIds.isEmpty()){
            Sage100InvoiceHandler.rollupCYPYTotals(accountIds, null);
        }

        // Invoke rollupDollarsSoldOnCustomerHistory method if there are valid records to process
        system.debug('#### customerIds : '+customerIds);
        if(!customerIds.isEmpty()){
            Sage100InvoiceHandler.rollupDollarsSoldOnCustomerHistory(customerIds, monthSet, yearSet, externalKeySet);
        }
    }

    // Method to handle before delete logic for SAGE100_Sage100InvoiceHandler.
    public static void beforeDelete(map<Id,CommercientSF8__AR_INVOICEHISTORYHEADER__c> oldMap) {
        Set<Id> InvoiceIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(CommercientSF8__AR_INVOICEHISTORYHEADER__c Invoice : oldMap.values()){
            // Check if account was not null on deleted Sage100InvoiceHandler
            if(Invoice.CommercientSF8__Account__c != null && Invoice.CommercientSF8__INVOICEDATE__c != null){
                InvoiceIds.add(Invoice.Id);
                accountIds.add(Invoice.CommercientSF8__Account__c);
            }
        }
        // Invoke rollupCYPYTotals method if there are valid records to process
        if(!accountIds.isEmpty()){
            Sage100InvoiceHandler.rollupCYPYTotals(accountIds,InvoiceIds);
        }
    }

    // Method to rollup PY_Historical_Sales_2 and CY_Historical_Sales_2 fields on account with sum of Invoice Total on Sage100InvoiceHandler
    public static void rollupCYPYTotals(Set<Id> accountIds, Set<Id> InvoiceIds){
        Map<Id,Account> accToUpdate = new Map<Id,Account>();
        String currentYear = String.valueOf(System.today().year());
        String previousYear = String.valueOf(System.today().year()-1);

        AggregateResult[] cyGroupedResults;
        AggregateResult[] pyGroupedResults;
        AggregateResult[] mostRecentInvoice;
        if(InvoiceIds == null || InvoiceIds.isEmpty()){
            // This will only execute for delete trigger. Fetch sum of Dollars_Sold from all current year Sage100InvoiceHandler records except deleted record group by account
            cyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Dollars_Sold__c) 
                                FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: currentYear
                                GROUP BY CommercientSF8__Account__c];
            // This will only execute for delete trigger. Fetch sum of Dollars_Sold from all previous year Sage100InvoiceHandler records except deleted record group by account
            pyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Dollars_Sold__c) 
                                FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: previousYear
                                GROUP BY CommercientSF8__Account__c];
            //Get most recent invoice date for an account
            mostRecentInvoice = [SELECT CommercientSF8__Account__c, MAX(CommercientSF8__INVOICEDATE__c) 
                                                    FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                                    WHERE CommercientSF8__Account__c IN : accountIds
                                                    GROUP BY CommercientSF8__Account__c];
        }else{
            // This will only execute for insert and update trigger. Fetch sum of Dollars_Sold from all current year Sage100InvoiceHandler record group by account
            cyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Dollars_Sold__c) 
                                FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: currentYear AND Id Not IN : InvoiceIds
                                GROUP BY CommercientSF8__Account__c];
            // This will only execute for insert and update trigger. Fetch sum of Dollars_Sold from all previous year Sage100InvoiceHandler record group by account
            pyGroupedResults = [SELECT CommercientSF8__Account__c, SUM(Dollars_Sold__c) 
                                FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds AND Invoice_Year__c =: previousYear AND Id Not IN : InvoiceIds
                                GROUP BY CommercientSF8__Account__c];
            //Get most recent invoice date for an account
            mostRecentInvoice = [SELECT CommercientSF8__Account__c, MAX(CommercientSF8__INVOICEDATE__c) 
                                FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                WHERE CommercientSF8__Account__c IN : accountIds
                                AND Id Not IN : InvoiceIds
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

        // Reset PY_Historical_Sales_2 and CY_Historical_Sales_2 to 0 if no Sage100InvoiceHandler records found for an account
        for(Id accId : accountIds){
            if(!accToUpdate.containsKey(accId)){
                accToUpdate.put(accId,new Account(Id = accId, PY_Historical_Sales_2__c = 0, CY_Historical_Sales_2__c = 0));
            }
        }

        // Iterate over aggregate result to get most recent invoice date for an account and create instances of account records to be updated
        Set<Id> accountIdsWithMostRecentInvoiceDate = new Set<Id>();
        for (AggregateResult ar : mostRecentInvoice)  {
            System.debug('Account ID' + ar.get('CommercientSF8__Account__c'));
            System.debug('Max date' + ar.get('expr0'));
            Account acc = accToUpdate.get((Id)ar.get('CommercientSF8__Account__c'));
            if(acc == null){
                // Create new instance if account not already added in accounts to be updated.
                acc = new Account(Id = (Id)ar.get('CommercientSF8__Account__c'));
            }
            acc.Most_Recent_Sage100_Invoice__c = (Date) ar.get('expr0');
            accToUpdate.put((Id)ar.get('CommercientSF8__Account__c'),acc);
            accountIdsWithMostRecentInvoiceDate.add((Id)ar.get('CommercientSF8__Account__c'));
        }

        // Reset Most_Recent_Sage100_Invoice__c to null if no Sage100InvoiceHandler records found for an account
        for(Id accId : accountIds){
            if(!accToUpdate.containsKey(accId)){
                accToUpdate.put(accId,new Account(Id = accId, Most_Recent_Sage100_Invoice__c = null));
            }else if(!accountIdsWithMostRecentInvoiceDate.contains(accId)){
                Account acc = accToUpdate.get(accId);
                acc.Most_Recent_Sage100_Invoice__c = null;
                accToUpdate.put(acc.Id,acc);
            }
        }
        
        // Update account records
        if(!accToUpdate.isEmpty()){
            update accToUpdate.values();
        }
    }

    // Method to rollup Dollars_Sold on Customer_Sales_History with sum of Dollars_Sold on Sage100InvoiceHandler
    public static void rollupDollarsSoldOnCustomerHistory(Set<String> customerIds, Set<String> monthSet, Set<String> yearSet, Set<String> externalKeySet){
        system.debug('#### rollupDollarsSoldOnCustomerHistory');
        Map<String,Decimal> customerDollarsMap = new Map<String,Decimal>();
        Map<String,CommercientSF8__AR_INVOICEHISTORYHEADER__c> customerInvoiceMap = new Map<String,CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
        // Fetch all related Invoice for the customer
        for(CommercientSF8__AR_INVOICEHISTORYHEADER__c Invoice : [SELECT Id, CommercientSF8__Account__c, CommercientSF8__CUSTOMERNO__c, CommercientSF8__ARDIVISIONNO__c, Invoice_Year__c, 
                                                                            Invoice_Month__c, Dollars_Sold__c FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c 
                                                                            WHERE CommercientSF8__CUSTOMERNO__c =: customerIds AND Invoice_Month__c IN : monthSet AND Invoice_Year__c IN : yearSet]){

            // Generate external Id for Customer Sales History and rollup Dollars_Sold__c grouped by external id
            String externalId = Invoice.CommercientSF8__ARDIVISIONNO__c+'-'+Invoice.CommercientSF8__CUSTOMERNO__c+'-'+Invoice.Invoice_Year__c+'-'+Invoice.Invoice_Month__c;
            decimal dollarSum = customerDollarsMap.get(externalId);
            if(dollarSum == null){
                dollarSum = 0;
            }
            dollarSum += Invoice.Dollars_Sold__c;
            // Map of key to dollar sold total.
            customerDollarsMap.put(externalId,dollarSum);
            // Map of key to Invoice All Invoice with same key will have same values. so doesn't matter if override with each other.
            customerInvoiceMap.put(externalId,Invoice);
        }

        // Fetch existing Customer_Sales_History based on the external key generated above
        Map<String,Customer_Sales_History__c> customerSalesHistoryMap = new Map<String,Customer_Sales_History__c>();
        for(Customer_Sales_History__c csh : [SELECT Id, Name, Dollars_Sold__c, Customer__c, CustomerNo__c, External_Id__c, ARDivisionNo__c, FiscalYear__c, FiscalPeriod__c FROM Customer_Sales_History__c WHERE External_Id__c IN : externalKeySet]){
            customerSalesHistoryMap.put(csh.External_Id__c,csh);
        }

        system.debug('#### customerDollarsMap : '+customerDollarsMap);
        system.debug('#### customerInvoiceMap : '+customerInvoiceMap);
        system.debug('#### customerSalesHistoryMap : '+customerSalesHistoryMap);

        List<Customer_Sales_History__c> customerSalesHistoryToUpsert = new List<Customer_Sales_History__c>();
        for(String externalId : externalKeySet){
            system.debug('#### externalId : '+externalId);
            Customer_Sales_History__c csh = customerSalesHistoryMap.get(externalId);
            CommercientSF8__AR_INVOICEHISTORYHEADER__c Invoice = customerInvoiceMap.get(externalId);
            if(csh == null && Invoice != null){
                // If Customer_Sales_History doesn't exist, create a new instance
                csh = new Customer_Sales_History__c();
                csh.ARDivisionNo__c = Invoice.CommercientSF8__ARDIVISIONNO__c;
                csh.Customer__c = Invoice.CommercientSF8__Account__c;
                csh.CustomerNo__c = Invoice.CommercientSF8__CUSTOMERNO__c;
                csh.FiscalYear__c = Invoice.Invoice_Year__c;
                csh.FiscalPeriod__c = Invoice.Invoice_Month__c;
                csh.External_Id__c = externalId;
                csh.Name = externalId;
            }
            if(customerDollarsMap.containsKey(externalId)){
                csh.Dollars_Sold__c = customerDollarsMap.get(externalId);
                if(Invoice != null){
                    csh.Customer__c = Invoice.CommercientSF8__Account__c;
                }
            }else{
                csh.Dollars_Sold__c = 0;
                if(Invoice != null){
                    csh.Customer__c = Invoice.CommercientSF8__Account__c;
                }
            }
            customerSalesHistoryToUpsert.add(csh);
        }
        system.debug('#### customerSalesHistoryToUpsert : '+customerSalesHistoryToUpsert);
        upsert customerSalesHistoryToUpsert External_Id__c;
    }
}