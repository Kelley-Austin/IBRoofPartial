public class OpenInvoiceSageHelper {
    private List<Open_Invoice__c> oldList;
    private List<Open_Invoice__c> newList;
    
    public OpenInvoiceSageHelper(List<Open_Invoice__c> oldList, List<Open_Invoice__c> newList) {
    	this.oldList = (oldList == null) ? new List<Open_Invoice__c>() : oldList;
    	this.newList = (newList == null) ? new List<Open_Invoice__c>() : newList;
    }

    public void execute() {
        Set<String> accExternalIds = new Set<String>();

        for (Open_Invoice__c openInvoice : this.newList) {
            if (String.isBlank(openInvoice.ARDivisionNo__c) == true)
                continue;

            if (String.isBlank(openInvoice.SageCustomerNo__c) == true)
                continue;

            accExternalIds.add(openInvoice.ARDivisionNo__c + '-' + openInvoice.SageCustomerNo__c);
        }

        List<Account> accList = [SELECT Id, External_Id__c FROM Account WHERE External_Id__c IN :accExternalIds];
        Map<String,Account> accByExternalIdMap = new Map<String,Account>();

        for (Account acc : accList) {
            accByExternalIdMap.put(acc.External_Id__c, acc);
        }

        for (Open_Invoice__c openInvoice : this.newList) {
            if (String.isBlank(openInvoice.ARDivisionNo__c) == true)
                continue;

            if (String.isBlank(openInvoice.SageCustomerNo__c) == true)
                continue;

            String externalId = openInvoice.ARDivisionNo__c + '-' + openInvoice.SageCustomerNo__c;
            Account acc = accByExternalIdMap.get(externalId);

            if (acc == null)
                continue;

            if (openInvoice.CustomerNo__c == acc.Id)
                continue;

            openInvoice.CustomerNo__c = acc.Id;
        }
    }
}