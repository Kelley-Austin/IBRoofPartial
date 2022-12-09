@isTest 
private class WarrantyRestApiForIBRoofTest {

    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void service_call() {
        Warranty__c w = new Warranty__c();
        w.Warranty_Number__c = '123456';
        w.Name = '1234567890';
        w.Warrantied_Account_Copy__c = 'Test';
        w.Roofing_Company_Copy__c = 'Saif';
        insert w;
        w.Roofing_Company_Copy__c = 'abc';
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
		update w;
        //your webserive call code

        Test.StopTest();


    }
}