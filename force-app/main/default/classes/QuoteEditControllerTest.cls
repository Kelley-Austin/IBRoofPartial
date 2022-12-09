@isTest
private class QuoteEditControllerTest {
    static TestMethod void quoteEditTest() {
        Account anAccount = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert anAccount;
		
		Project__c aProject = new Project__c(Name='test', Street__c='1234 Street St', City__c='Roseville', State__c='CA');
        insert aProject;

        Opportunity anOpportunity = new Opportunity(Name = 'created by quick action',
                                    CloseDate = Date.today().addDays(14),
                                    Project__c = aProject.Id,
                                    AccountId = anAccount.Id,
                                    StageName = 'Estimating');
        insert anOpportunity;
        
        Product2 aProduct = new Product2(Name = 'test', Family = 'VENTS', ProductCode = '1-50w', Bulk_Box_Price__c = 10.00, Color__c = 'red', Product_Size__c = '1"');
        insert aProduct;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice = 11.00, Product2Id = aProduct.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
        insert pbe;

        Quote aQuote = new Quote(Project2__c = aProject.Id, 
                                Name = 'test', 
                                Account__c = anAccount.Id,
                                OpportunityId = anOpportunity.Id,
                                Pricebook2Id = pbe.Pricebook2Id);
        insert aQuote;

        OpportunityLineItem oppLine = new OpportunityLineItem(Product2Id = aProduct.Id,
                                                            OpportunityId = anOpportunity.Id,
                                                            Quantity = 1, 
                                                            PricebookEntryId = pbe.Id, 
                                                            UnitPrice = pbe.unitPrice);
        insert oppLine;

        QuoteLineItem quoteLine = new QuoteLineItem (OpportunityLineItemId = oppLine.Id,
                                                    Product2Id = aProduct.Id,
                                                    QuoteId = aQuote.Id,
                                                    Quantity = 1, 
                                                    PricebookEntryId = pbe.Id, 
                                                    UnitPrice = pbe.unitPrice);
        insert quoteLine;
        ApexPages.StandardController sc = new ApexPages.StandardController(aQuote);
        
        QuoteEditController controller = new QuoteEditController(sc);

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

        controller.setTaxAndShippingAddress();

        controller.uploadedFileName = 'test';
        controller.uploadedFileString = 'test';
        controller.addFile();
        controller.selectedFile = 0;
        controller.removeFile();

        controller.selectProductFamily();
        
        controller.finalizeQuote();
        
        controller.saveQuote();

        QuoteEditController.getRecentProjects();

        QuoteEditController.searchProjects('test');

        QuoteEditController.getCurrentUserName();

        String projectJSON = JSON.serialize(aProject);
        QuoteEditController.insertNewProject(projectJSON);

        QuoteEditController.getProjectById(aProject.Id);

        QuoteEditController.insertQuoteTemplate(new Set<Id>());
    }
}