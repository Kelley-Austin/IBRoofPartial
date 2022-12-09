@isTest
private class QuoteProjectControllerTest {

    static testMethod void myUnitTest() {
       
		Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
		
		Project__c project = new Project__c();
        insert project;
        
        Product2 p = new Product2(Name = 'test', Family = 'VENTS', ProductCode = '1-50w', Bulk_Box_Price__c = 10.00, Color__c = 'red', Product_Size__c = '1"');
        insert p;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice = 11.00, Product2Id = p.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
        insert pbe;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(project);
        
        QuoteProjectController controller = new QuoteProjectController(sc);
        
        controller.safeAction();
        controller.getProductFamilys();
        
        controller.productSku = '1-50w';
        controller.productFamily = 'VENTS';
        controller.productName = 'test';
        controller.productColor = 'red';
        controller.productSize = '1"';
        
        controller.runSearch();
        
        controller.selectedPricebookEntry = pbe.Id;
        


        
        controller.newProductSku = 'test';
    	controller.newProductFamily = 'VENTS';
    	controller.newProductName = 'Test new';
    	controller.newProductColor = 'Red';
    	controller.newProductSize = '1"';
    	controller.newProductPrice = 20.00;
        
		controller.back();
        
        controller.addtoCart();
        
        controller.finalizeQuote();
        controller.addAccountToQuote();
        
        controller.saveQuote();
        
        QuoteProjectController.insertQuoteTemplate(new Set<Id>());
        
        QuoteProjectController.AccountQuoteRow aqr = new QuoteProjectController.AccountQuoteRow(project, standardPricebook,a, new List<QuoteProjectController.QuoteRow>(), 100.00);
        
        
    }
}