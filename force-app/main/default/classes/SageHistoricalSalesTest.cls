@isTest
private class SageHistoricalSalesTest {

    static testMethod void testEndpoint(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

	    req.requestURI = '/services/apexrest/sageAccount'; 
        req.httpMethod = 'Post';
        
        String payload = '{ "allOrNone": false,' +
                        + ' "records" : ['
                            + '{ "attributes" : { "type": "Account" },'
                            + '"External_Id" : "00-JGA042"'
                            + '}'
                            +']'
                        +'}';

        req.requestBody = Blob.valueOf(payload);  // TODO: put payload to cover class
        
        RestContext.request = req;
        RestContext.response = res;
        
        SageHistoricalSales.doPost();
    }



}