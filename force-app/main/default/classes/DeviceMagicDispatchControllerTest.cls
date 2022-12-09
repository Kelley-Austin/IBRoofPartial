@isTest
public class DeviceMagicDispatchControllerTest {
	
	@isTest
	static void testPage() {
		insert new Device_Magic__c(API_Token__c = 'test', Base_URL__c = 'https://www.devicemagic.com');
		
		Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;
        
        Opportunity o = new Opportunity(AccountId=a.Id, Name='test', StageName='New',CloseDate=Date.today());
        insert o;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u = new User(Alias = 'test', Email='test@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testtesttest.username@user.c');
        insert u;
        
        Device__c customDevice = new Device__c(Field_Tech__c=u.Id, Device_Id__c='test', Identifier__c='test', Owner__c='test', Description__c='test');
		insert customDevice;
        
        System.JSONParser parser = System.JSON.createParser('{"id":12,"name":"test","namespace":"namespace","version":"version","description":"description","group":"group"}');
        DeviceMagicService.Form form = new DeviceMagicService.Form(parser);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        
		DeviceMagicDispatchController dm = new DeviceMagicDispatchController(sc);
        
        dm.formMap.put('test',form);
        dm.selectedForm = 'test';
        dm.deviceMap.put(customDevice.Identifier__c,customDevice);
        dm.selectedDevice=customDevice.Identifier__c;
        
        dm.dispatch();
		
        Test.setMock(HttpCalloutMock.class, new MockDeviceMagicResponseGenerator());
        
        Test.startTest();
		dm.action();
        dm.dispatch();
        dm.cancel();
        Test.stopTest();
       
	}    
}