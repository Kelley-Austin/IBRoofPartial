public class DailyShipmentSageHelper {
    private List<DailyShipment__c> oldList;
    private List<DailyShipment__c> newList;
    
    public DailyShipmentSageHelper(List<DailyShipment__c> oldList, List<DailyShipment__c> newList) {
    	this.oldList = (oldList == null) ? new List<DailyShipment__c>() : oldList;
    	this.newList = (newList == null) ? new List<DailyShipment__c>() : newList;
    }

    public void execute() {
        Set<String> accExternalIds = new Set<String>();

        for (DailyShipment__c dailyShipment : this.newList) {
            if (String.isBlank(dailyShipment.ARDivisionNo__c))
                continue;

            if (String.isBlank(dailyShipment.CustomerNo__c))
                continue;

            accExternalIds.add(dailyShipment.ARDivisionNo__c + '-' + dailyShipment.CustomerNo__c);
        }

        List<Account> accList = [SELECT Id, External_Id__c FROM Account WHERE External_Id__c IN :accExternalIds];
        Map<String,Account> accByExternalIdMap = new Map<String,Account>();

        for (Account acc : accList) {
            accByExternalIdMap.put(acc.External_Id__c, acc);
        }

        for (DailyShipment__c dailyShipment : this.newList) {
            if (String.isBlank(dailyShipment.ARDivisionNo__c))
                continue;

            if (String.isBlank(dailyShipment.CustomerNo__c))
                continue;

            String externalId = dailyShipment.ARDivisionNo__c + '-' + dailyShipment.CustomerNo__c;
            Account acc = accByExternalIdMap.get(externalId);

            if (acc == null)
                continue;

            if (dailyShipment.Account__c == acc.Id)
                continue;

            dailyShipment.Account__c = acc.Id;
        }
    }
}