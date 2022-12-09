public class LeadRegionHelper extends RegionHelper {

    public LeadRegionHelper() {
        super();
    }
    
    public void addRegion(List<Lead> leadList) {
        Set<String> zipCodes = new Set<String>();
        
        for (Lead theLead : leadList) {
            zipCodes.add(theLead.PostalCode);
        }
        zipCodes.remove(null);

        Map<String, Zipcode_Territory__c> zipCodeTerritories = this.getZipcodeTerritory(zipCodes);
        
        for (Lead theLead : leadList) {
            
            if (theLead.PostalCode == null)
                continue;
            
            if (zipCodeTerritories.containsKey(theLead.PostalCode) == false)
                continue;
            
            theLead.Region__c = zipCodeTerritories.get(theLead.PostalCode).Region__c;
        }
    }
}