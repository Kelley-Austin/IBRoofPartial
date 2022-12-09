@isTest
private class QuoteAccountControllerTest {

    static testMethod void myUnitTest() {
        Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
		
		Project__c project = new Project__c(Zip__c = '95758');
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

        Avalara_Tax_API__c settings = Avalara_Tax_API__c.getOrgDefaults();
        settings.username__c = 'test';
        settings.password__c = 'test';
        
        insert settings;

        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        QuoteAccountController controller = new QuoteAccountController(sc);
        
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

        QuoteAccountController.getRecentProjects();
        QuoteAccountController.searchProjects('test');
        QuoteAccountController.getCurrentUserName();

        controller.uploadedFileName = 'test';
        controller.uploadedFileString = 'test';
        controller.addFile();
        controller.removeFile();

        controller.selectProductFamily();

        controller.selectedLine = 0;
        controller.removeItem();

        controller.quoteObj.Project2__c = project.Id;
        controller.setTaxAndShippingAddress();
        
        controller.saveQuote();
        
        QuoteAccountController.insertQuoteTemplate(new Set<Id>());
  
        
    }
    
    static testMethod void myUnitTest2() {
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        QuoteAccountController controller = new QuoteAccountController(sc);
        
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

        controller.setTaxAndShippingAddress();
        
        controller.saveQuote();
        
        //controller.removeItem();
        
        QuoteAccountController.insertQuoteTemplate(new Set<Id>());
  
        
    }

    static testMethod void myUnitTest3() {
        Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
		
		Project__c project = new Project__c(Zip__c = '95758', Tax_Rate__c = '{"totalRate":0.072500,"rates":[{"type":"County","rate":0.002500,"name":"CA COUNTY TAX"},{"type":"State","rate":0.060000,"name":"CA STATE TAX"},{"type":"Special","rate":0.010000,"name":"CA SPECIAL TAX"}]}');
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        QuoteAccountController controller = new QuoteAccountController(sc);
        
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

        controller.uploadedFileName = 'test';
        controller.uploadedFileString = 'test';
        controller.addFile();
        controller.selectedFile = 0;
        controller.removeFile();

        controller.quoteObj.Project2__c = project.Id;
        controller.setTaxAndShippingAddress();
        
        controller.saveQuote();
        
        QuoteAccountController.insertQuoteTemplate(new Set<Id>());
  
        
    }
}