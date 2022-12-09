@isTest
private class SageContactEndpointTest {

    static testMethod void testEndpoint(){

        Account acc = new Account(External_Id__c='00-JGA042', Name='test', BillingStreet='test', BillingCity='test', BillingState='test', BillingPostalCode='00000', Account_Email__c = 'test@email.com', ARDivisionNo__c='00', CustomerNo__c='JGA042', ContactCode__c='TEST');
        insert acc;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

	    req.requestURI = '/services/apexrest/sageContact'; 
        req.httpMethod = 'Post';
        
        String payload = '{ "allOrNone": false,' +
                        + ' "records" : ['
                            + '{ "attributes" : { "type": "Contact" },'
                            + '"Sage_Contact_Code" : "00-JGA042-TEST",'
                            + '"ARDivisionNo": "00",'
                            + '"CustomerNo": "JGA042",'
                            + '"ContactCode": "TEST",'
                            + '"ContactName": "test"'
                            + '}'
                            +']'
                        +'}';

        req.requestBody = Blob.valueOf(payload);  // TODO: put payload to cover class
        
        RestContext.request = req;
        RestContext.response = res;
        
        SageContactEndpoint.doPost();
    }
}