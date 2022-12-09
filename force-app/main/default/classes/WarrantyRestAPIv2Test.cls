@isTest
private class WarrantyRestAPIv2Test {
    
    static testMethod void testEndpoint(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

	    req.requestURI = '/services/apexrest/warrantyformv2'; 
        req.httpMethod = 'Post';
        
        String payload = '{'
                        +  '"WarrantyId": "test",' 
                        +  '"warrantyaccount": "test",' 
                        +  '"warrantyaccountemail": "test@email.com",'
                        +  '"roofingcompany": "test",' 
                        +  '"roofingcompanyemail": "test@email.com",' 
                        +  '"WarrantyType": "test",' 
                        +  '"WarrantyLength": "test",'
                        +  '"WarrantyStartDate": "1/12/2020",' 
                        +  '"WarrantyNumber": "test",'
                        +  '"IssuanceDate": "1/12/2020",'
                        +  '"WarrantyExpirationDate": "1/12/2022",'
                        +  '"BuildingType": "test",'
                        +  '"Stage": "test",'
                        +  '"BuildingOwnerCompanyName": "test",'
                        +  '"SameAsOwnerAddress": true,'
                        +  '"ProjectName": "test",'
                        +  '"ProjectAddress": "test",'
                        +  '"ProjectState": "test",'
                        +  '"ProjectPhoneNumber": "test",'
                        +  '"ProjectCity": "test",'
                        +  '"ProjectZipCode": "12345",'
                        +  '"PrimaryBuildingUse": "test",'
                        +  '"JobType": "test",'
                        +  '"MembraneType": "test",'
                        +  '"MembraneColor": "test",'
                        +  '"MembraneThickness": "test",'
                        +  '"RoofSize": "2000",'
                        +  '"TypeofStructure": "test",'
                        +  '"WarrantyCertification": "test",'
                        +  '"InstallationAddress": "test",'
                        +  '"InstallationCity": "test",'
                        +  '"InstallationState": "test",'
                        +  '"InstallationZipCode": "test",'
                        +  '"ProjectEmail": "test",'
                        +  '"ProjectNameBldg": "test"'
                        +'}';

        req.requestBody = Blob.valueOf(payload);  // TODO: put payload to cover class
        
        RestContext.request = req;
        RestContext.response = res;
        
        WarrantyRestAPIv2.createWarranty();
    }

}