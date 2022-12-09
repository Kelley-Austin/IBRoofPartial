public class LeadTerritoryHelper {
    private List<Lead> oldList;
    private List<Lead> newList;
    
    public LeadTerritoryHelper (List<Lead> oldList, List<Lead> newList) {
    	this.oldList = (oldList == null) ? new List<Lead>() : oldList;
    	this.newList = (newList == null) ? new List<Lead>() : newList;
    }
    
    public void execute() {
    	
    	List<Lead> leadsToAddRegion = new List<Lead>();
        
        for (Lead theLead : this.newList) {
            if (theLead.Region__c != null)
                continue;
            
            leadsToAddRegion.add(theLead);
        }
    	
        LeadRegionHelper helper = new LeadRegionHelper();
        helper.addRegion(leadsToAddRegion);
    }
}