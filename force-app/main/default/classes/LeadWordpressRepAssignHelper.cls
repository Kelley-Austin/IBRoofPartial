public class LeadWordpressRepAssignHelper {
    private List<Lead> oldList;
    private List<Lead> newList;
    
    public LeadWordpressRepAssignHelper (List<Lead> oldList, List<Lead> newList) {
    	this.oldList = (oldList == null) ? new List<Lead>() : oldList;
    	this.newList = (newList == null) ? new List<Lead>() : newList;
    }
    
    public void executeBefore() {
        Set<String> emailSet = new Set<String>();

        for (Lead theLead : this.newList) {
            if (String.isBlank(theLead.IB_Roof_Website_Rep_Email__c))
                continue;

            emailSet.add(theLead.IB_Roof_Website_Rep_Email__c.toLowerCase());
        }

        List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :emailSet];
        Map<String, User> userByEmail = new Map<String, User>();

        for (User theUser : userList) {
            if (emailSet.contains(theUser.Email.toLowerCase())) 
                userByEmail.put(theUser.Email.toLowerCase(), theUser);
        }

        for (Lead theLead : this.newList) {

            if (theLead.Rep_Assigned_By_Email__c == true)
                continue;
            
            if (String.isBlank(theLead.IB_Roof_Website_Rep_Email__c))
                continue;
            
            if (userByEmail.containsKey(theLead.IB_Roof_Website_Rep_Email__c.toLowerCase()) == false)
                continue;

            if (theLead.OwnerId == userByEmail.get(theLead.IB_Roof_Website_Rep_Email__c.toLowerCase()).Id)
                continue;
            
            theLead.Rep_Assigned_By_Email__c = true;
            theLead.OwnerId = userByEmail.get(theLead.IB_Roof_Website_Rep_Email__c.toLowerCase()).Id;
        }
    }
}