public virtual class RegionHelper {

    public RegionHelper() {}
    
    public Map<String, Zipcode_Territory__c> getZipcodeTerritory(Set<String> zipCodes) {
        Map<String, Zipcode_Territory__c> zipCodeTerritoryMap = new Map<String, Zipcode_Territory__c>();
        
        for (Zipcode_Territory__c territory : [SELECT Zip_Code__c, Territory_Number__c, Region__c FROM Zipcode_Territory__c WHERE Zip_Code__c IN :zipCodes]) {
            zipCodeTerritoryMap.put(territory.Zip_Code__c, territory);
        }
        
        return zipCodeTerritoryMap;
    }
}