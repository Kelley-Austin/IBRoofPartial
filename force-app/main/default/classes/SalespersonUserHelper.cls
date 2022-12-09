public class SalespersonUserHelper {
    private List<Salesperson__c> oldList;
    private List<Salesperson__c> newList;
    
    public SalespersonUserHelper (List<Salesperson__c> oldList, List<Salesperson__c> newList) {
    	this.oldList = (oldList == null) ? new List<Salesperson__c>() : oldList;
    	this.newList = (newList == null) ? new List<Salesperson__c>() : newList;
    }

    public void execute() {
        Set<String> salespersonNumbers = new Set<String>();

        for (Salesperson__c sp : this.newList) {
            if (String.isBlank(sp.SalespersonNo__c))
                continue;

            salespersonNumbers.add(sp.SalespersonNo__c);
        }

        List<User> userList = [SELECT Id, MAS_ID__c FROM User WHERE MAS_ID__c IN :salespersonNumbers];
        Map<String,User> userByMasIdMap = new Map<String,User>();

        for (User u : userList) {
            userByMasIdMap.put(u.MAS_ID__c, u);
        }

        for (Salesperson__c sp : this.newList) {
            
            if (String.isBlank(sp.SalespersonNo__c))
                continue;

            if (userByMasIdMap.containsKey(sp.SalespersonNo__c) == false)
                continue;

            sp.User__c = userByMasIdMap.get(sp.SalespersonNo__c).Id;
        }
    }
}