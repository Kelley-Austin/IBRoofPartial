public class AccountSalespersonHelper {
    private List<Account> oldList;
    private List<Account> newList;
    
    public AccountSalespersonHelper (List<Account> oldList, List<Account> newList) {
    	this.oldList = (oldList == null) ? new List<Account>() : oldList;
    	this.newList = (newList == null) ? new List<Account>() : newList;
    }
    
    public void execute() {
        Set<String> salespersonExternalIds = new Set<String>();

        for (Account acc : this.newList) {
            if (String.isBlank(acc.SalespersonDivisionNo__c))
                continue;

            if (String.isBlank(acc.SalespersonNo__c))
                continue;

            salespersonExternalIds.add(acc.SalespersonDivisionNo__c + '-' + acc.SalespersonNo__c);
        }

        List<Salesperson__c> salespersonList = [SELECT Id, External_Id__c, User__r.Id, User__r.isActive FROM Salesperson__c WHERE External_Id__c IN :salespersonExternalIds];
        Map<String,Salesperson__c> salespersonByExternalIdMap = new Map<String,Salesperson__c>();

        for (Salesperson__c sp : salespersonList) {
            salespersonByExternalIdMap.put(sp.External_Id__c, sp);
        }

        for (Account acc : this.newList) {
            if (String.isBlank(acc.SalespersonDivisionNo__c))
                continue;

            if (String.isBlank(acc.SalespersonNo__c))
                continue;

            String externalId = acc.SalespersonDivisionNo__c + '-' + acc.SalespersonNo__c;
            Salesperson__c sp = salespersonByExternalIdMap.get(externalId);

            if (sp == null)
                continue;

            if (acc.Sage_Salesperson_No__c != sp.Id)
                acc.Sage_Salesperson_No__c = sp.Id;

            if (sp.User__r.Id == null)
                continue;
            
            if (sp.User__r.isActive == false)
                continue;

            if (acc.OwnerId != sp.User__r.Id)
                acc.OwnerId = sp.User__r.Id;
        }
    }
}