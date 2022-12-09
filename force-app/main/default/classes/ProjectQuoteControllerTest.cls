@isTest
public class ProjectQuoteControllerTest {

	@isTest
	static void testQuote() {
		
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        
        ProjectQuoteController pq = new ProjectQuoteController(sc);
        
        pq.safeAction();
        pq.getProductFamilys();
        
        pq.productSku = '1-50w';
        pq.productFamily = 'VENTS';
        pq.productName = 'test';
        pq.productColor = 'red';
        pq.productSize = '1"';
        
        pq.runSearch();
        
        pq.selectedPricebookEntry = pbe.Id;
        
        pq.addtoCart();
        
        pq.save();
        
        pq.cancel();
	}
    
}