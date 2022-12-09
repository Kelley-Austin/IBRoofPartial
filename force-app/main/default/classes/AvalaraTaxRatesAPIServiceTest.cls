@isTest
private class AvalaraTaxRatesAPIServiceTest {
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"totalRate":0.072500,"rates":[{"type":"County","rate":0.002500,"name":"CA COUNTY TAX"},{"type":"State","rate":0.060000,"name":"CA STATE TAX"},{"type":"Special","rate":0.010000,"name":"CA SPECIAL TAX"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    static testMethod void myTest() {
        Project__c project = new Project__c(Zip__c = '95758');
        insert project;

        Avalara_Tax_API__c settings = Avalara_Tax_API__c.getOrgDefaults();
        settings.username__c = 'test';
        settings.password__c = 'test';
        insert settings;

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();

        AvalaraTaxRatesAPIService.getTaxRates('95650', 'US');
        
        Test.StopTest();
        
    }
}