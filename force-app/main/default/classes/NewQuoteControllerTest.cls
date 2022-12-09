/**
* Name         : NewQuoteControllerTest
* Description  : Test class for NewQuoteController
* Author       : Kelley Austin
* Created On   : 12/01/2022
*/
@isTest
private class NewQuoteControllerTest {
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

    @testSetup static void setup() {
        Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;

        Project__c project = new Project__c(Zip__c = '95758', Tax_Rate__c = '{"totalRate":0.072500,"rates":[{"type":"County","rate":0.002500,"name":"CA COUNTY TAX"},{"type":"State","rate":0.060000,"name":"CA STATE TAX"},{"type":"Special","rate":0.010000,"name":"CA SPECIAL TAX"}]}');
        insert project;
        
        Product2 p = new Product2(Name = 'test', Family = 'VENTS', ProductCode = '1-50w', Bulk_Box_Price__c = 10.00, Color__c = 'red', Product_Size__c = '1"');
        insert p;
        
        Opportunity opp = new Opportunity(AccountId=a.Id, Name='test', StageName='New',CloseDate=Date.today());
        insert opp;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice = 11.00, Product2Id = p.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
		insert pbe;
        
        Quote quote = new Quote(Project2__c = project.Id,Name = a.Name, OpportunityId = opp.Id, Account__c = a.Id, Pricebook2Id = standardPricebook.Id, Shipping_Zip_Postal_Code__c=99501);
        insert quote;

        QuoteLineItem qli = new QuoteLineItem(Product2Id = p.Id, QuoteId = quote.Id,Quantity = 1,PricebookEntryId = pbe.Id,UnitPrice = 12,Description = '');
        insert qli;

        QuoteLineItem qli2 = new QuoteLineItem(Product2Id = p.Id, QuoteId = quote.Id,Quantity = 1,PricebookEntryId = pbe.Id,UnitPrice = 12,Description = '');
        insert qli2;
    }

    static testMethod void testGetAccountDetails() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Map<String, Object> result = NewQuoteController.getAccountDetails(acc.Id);
        Test.stopTest();
        System.assertEquals(result.get('result'),'test');
    }

    static testMethod void testGetLocalTaxRates() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        Map<String, Object> result = NewQuoteController.getLocalTaxRates(qt);
        Test.stopTest();
    }

    static testMethod void testUpdateQuoteWithLocalTax() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Quote qt = [SELECT Id FROM Quote];
        Test.startTest();
        NewQuoteController.updateQuoteWithLocalTax(new List<Id>{qt.Id});
        qt.ShippingPostalCode = '99501';
        update qt;
        NewQuoteController.updateQuoteWithLocalTax(new List<Id>{qt.Id});
        Test.stopTest();
    }

    static testMethod void testSaveNewQuote() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Project__c p = [SELECT Id FROM Project__c LIMIT 1];
        Quote qt = new Quote(Name = a.Name, Account__c = a.Id, Shipping_Zip_Postal_Code__c=99501, ShippingPostalCode = '99501', Project2__c = p.Id);
        Test.startTest();
        Map<String, Object> result = NewQuoteController.saveNewQuote(qt,'test','test');
        Test.stopTest();
        System.assertEquals(result.get('result'),'Quote created succefully');
        NewQuoteController.TaxRateWrapper taxwrapper = new NewQuoteController.TaxRateWrapper();
        NewQuoteController.ProjectData projwrapper = new NewQuoteController.ProjectData('100', 'test 12345, US');
    }
}