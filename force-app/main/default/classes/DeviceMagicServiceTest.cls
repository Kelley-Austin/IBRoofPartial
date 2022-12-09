@isTest
public class DeviceMagicServiceTest {
	
	@isTest
	static void testgetDevicesFromDeviceMagic() {

        try{
		DeviceMagicService service = new DeviceMagicService();
    	DeviceMagicService.DevicesPayload devicePayload = service.getDevicesFromDeviceMagic();
        } catch(Exception e) {}
        
		insert new Device_Magic__c(API_Token__c = 'test', Base_URL__c = 'https://www.devicemagic.com');
        
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
		DeviceMagicService service = new DeviceMagicService();
    	DeviceMagicService.DevicesPayload devicePayload = service.getDevicesFromDeviceMagic();
    	
    	Test.stopTest();
	}    
	
	@isTest
	static void testgetFormsFromDeviceMagic() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		insert new Device_Magic__c(API_Token__c = 'test', Base_URL__c = 'https://www.devicemagic.com');
		Test.startTest(); 
		DeviceMagicService service = new DeviceMagicService();
    	DeviceMagicService.FormsPayload devicePayload = service.getFormsFromDeviceMagic();
    	Test.stopTest();
    	
	}    
	@isTest
	static void testdispatchPayload() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		Map<String,String> testMap = new Map<String,String>();
        
        testMap.put('test','test');
        
        System.JSONParser parser = System.JSON.createParser('{"id":12,"name":"test","namespace":"namespace","version":"version","description":"description","group":"group"}');
        DeviceMagicService.Form form = new DeviceMagicService.Form(parser);
        FormWrapper wrapper = new FormWrapper(form,testMap);
        
		insert new Device_Magic__c(API_Token__c = 'test', Base_URL__c = 'https://www.devicemagic.com');
        
		Test.startTest(); 
		DeviceMagicService service = new DeviceMagicService();
    	service.dispatchPayload(wrapper, 'test');
    	Test.stopTest();
    	
	} 
    
}