public class CustomerSalesHistoryAccountHelper {
    private List<Customer_Sales_History__c> oldList;
    private List<Customer_Sales_History__c> newList;
    
    public CustomerSalesHistoryAccountHelper (List<Customer_Sales_History__c> oldList, List<Customer_Sales_History__c> newList) {
    	this.oldList = (oldList == null) ? new List<Customer_Sales_History__c>() : oldList;
    	this.newList = (newList == null) ? new List<Customer_Sales_History__c>() : newList;
    }
    
    public void execute() {
        Set<String> accExternalIds = new Set<String>();

        for (Customer_Sales_History__c csh : this.newList) {
            if (String.isBlank(csh.ARDivisionNo__c))
                continue; 
            
            if (String.isBlank(csh.CustomerNo__c))
                continue;
            
            accExternalIds.add(csh.ARDivisionNo__c + '-' + csh.CustomerNo__c);
        }
        
        // map dollars sold
        for (Customer_Sales_History__c csh : this.newList) {
            if (csh.DollarsSold__c == null)
                continue;
            
            try {
            	csh.Dollars_Sold__c = Decimal.valueOf(csh.DollarsSold__c);
            } catch (Exception e){
                system.debug(e.getMessage());
            }
        }
            

        List<Account> accList = [SELECT Id, External_Id__c FROM Account WHERE External_Id__c IN :accExternalIds];
        Map<String,Account> accByExternalIdMap = new Map<String,Account>();

        for (Account acc : accList) {
            accByExternalIdMap.put(acc.External_Id__c, acc);
        }

        for (Customer_Sales_History__c csh : this.newList) {
            if (String.isBlank(csh.ARDivisionNo__c))
                continue; 
            
            if (String.isBlank(csh.CustomerNo__c))
                continue;

            String externalId = csh.ARDivisionNo__c + '-' + csh.CustomerNo__c;
            Account acc = accByExternalIdMap.get(externalId);

            if (acc == null)
                continue;

            if (csh.Customer__c == acc.Id)
                continue;
            
            csh.Customer__c = acc.Id;
        }
    }
}