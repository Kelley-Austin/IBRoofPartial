@isTest
public class InspectionTriggerHelperTest {
	
	@isTest
	static void testTrigger() {
		
		Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
		
		Opportunity o = new Opportunity(AccountId=a.Id, Name='testProject', StageName='New',CloseDate=Date.today());
        insert o;
        
        String name = [SELECT Name FROM Opportunity WHERE Id=:o.Id].Name;
        
        Warranty__c w = new Warranty__c(Name='test');
        insert w;
		
		Inspection__c i = new Inspection__c(Warranty_No__c='test', Dispatched_Project_Name__c=name);
		insert i;
	}  
    
    @isTest
	static void testTrigger2() {
		
		Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
		
		Opportunity o = new Opportunity(AccountId=a.Id, Name='testProject', StageName='New',CloseDate=Date.today());
        insert o;
        
        String name = [SELECT Name FROM Opportunity WHERE Id=:o.Id].Name;
        
        Warranty__c w = new Warranty__c(Name='test');
        insert w;
		
		Inspection__c i = new Inspection__c(Warranty_No__c='test', Dispatched_Project_Name__c=name);
		insert i;
        
        Test.startTest();
        
        update i;
        delete i;
        undelete i;
        
        Test.stopTest();
	}    
}