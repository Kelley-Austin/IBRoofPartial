@isTest
private class QuoteAccountHelperTest {

    static testMethod void myUnitTest() {
    	Project__c project = new Project__c(Zip__c = '95758', Tax_Rate__c = '{"totalRate":0.072500,"rates":[{"type":"County","rate":0.002500,"name":"CA COUNTY TAX"},{"type":"State","rate":0.060000,"name":"CA STATE TAX"},{"type":"Special","rate":0.010000,"name":"CA SPECIAL TAX"}]}');
        insert project;
    	Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
		
		Opportunity o = new Opportunity(AccountId=a.Id, Name='test', StageName='New',CloseDate=Date.today());
        insert o;
        
        Product2 p = new Product2(Name = 'test', Family = 'VENTS', ProductCode = '1-50w', Bulk_Box_Price__c = 10.00, Color__c = 'red', Product_Size__c = '1"');
        insert p;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice = 11.00, Product2Id = p.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
        insert pbe;
        
        Quote quote = new Quote(Name = a.Name, OpportunityId = o.Id, Account__c = a.Id, Pricebook2Id = standardPricebook.Id, Shipping_Zip_Postal_Code__c=99501, Project2__c = project.Id);
        insert quote;
        
        //Quote qt = new Quote(Name ='test', OpportunityId = o.id, Project2__c = project.Id);
        //insert qt;
       

        
    }
}