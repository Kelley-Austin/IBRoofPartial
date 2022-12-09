@isTest
public class LeadTerritoryTriggerTest {
	
	@isTest
	static void testLeadInsert() {
		
		Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
	        List<QueuesObject >  qus = new List<QueuesObject >();
	        
	        QueuesObject q1 = new QueueSObject(QueueID = g1.Id, SobjectType = 'Zipcode_Territory__c');
	        qus.add(q1);
	        
	        QueuesObject q2 = new QueuesObject (QueueID = g1.Id, SobjectType = 'Lead'); 
			qus.add(q2);
			
			insert qus;
		}
		
		Zipcode_Territory__c zt = new Zipcode_Territory__c(Zip_Code__c = '12345', OwnerId = g1.Id);
		insert zt;
		
		Lead l = new Lead(LastName = 'test', Company = 'test', LeadSource = 'Other', Status = 'New', PostalCode = '12345');
		insert l;
		
        update l;
	}    
}