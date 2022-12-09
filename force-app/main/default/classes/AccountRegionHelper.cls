public class AccountRegionHelper extends RegionHelper {
    
    public AccountRegionHelper() {
        super();
    }
    
    public void addRegion(List<Account> accList) {
        Set<String> zipCodes = new Set<String>();
        
        for (Account acc : accList) {
            zipCodes.add(acc.ShippingPostalCode);
            zipCodes.add(acc.BillingPostalCode);
        }
        zipCodes.remove(null);

        Map<String, Zipcode_Territory__c> zipCodeTerritories = this.getZipcodeTerritory(zipCodes);
        
        for (Account acc : accList) {
            String zipCode = (String.isBlank(acc.ShippingPostalCode) == false) ? acc.ShippingPostalCode : acc.BillingPostalCode;
            
            if (String.isBlank(zipCode))
                continue;
            
            if (zipCodeTerritories.containsKey(zipCode) == false)
                continue;
            
            acc.Account_Region__c = zipCodeTerritories.get(zipCode).Region__c;
        }
    }
}