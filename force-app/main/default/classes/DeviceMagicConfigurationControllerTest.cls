@isTest
public class DeviceMagicConfigurationControllerTest {
	
	@isTest
	static void testPage() {
		
		insert new Device_Magic__c(API_Token__c = 'test');
        
		DeviceMagicConfigurationController dm = new DeviceMagicConfigurationController();
		Device__c customDevice = new Device__c(Device_Id__c='test', Identifier__c='test', Owner__c='test', Description__c='test');
		insert customDevice;
		
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		PageReference pr = dm.action();
        PageReference pr2 = dm.saveDevices();
        
        DeviceMagicService.Device d = new DeviceMagicService.Device();
        DeviceMagicConfigurationController.DeviceWrapper dw = new DeviceMagicConfigurationController.DeviceWrapper(d);
		DeviceMagicConfigurationController.DeviceWrapper dw2 = new DeviceMagicConfigurationController.DeviceWrapper(customDevice);
	}    
}