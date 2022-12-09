public class DeviceMagicConfigurationController {
	
	public List<DeviceWrapper> deviceWrapperList {get;set;}
    
    public DeviceMagicConfigurationController() {
    	this.deviceWrapperList = new List<DeviceWrapper>();
    }
    
    public PageReference action() {
    	
        Map<String,Device__c> deviceMap = new Map<String,Device__c>();
        
        for (Device__c device : [SELECT Device_Id__c, Identifier__c, Owner__c, Field_Tech__c, Description__c FROM Device__c]){
            deviceMap.put(device.Device_Id__c, device);
        }
        
    	DeviceMagicService service;
    	DeviceMagicService.DevicesPayload devicePayload;
    	
    	try {
	    	service = new DeviceMagicService();
	    	devicePayload = service.getDevicesFromDeviceMagic();
    	} catch (Exception e) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    	
    	for (DeviceMagicService.Device d: devicePayload.devices) {
            
            if (deviceMap.containsKey(String.valueOf(d.id)) == true) {
                this.deviceWrapperList.add(new DeviceWrapper(deviceMap.get(String.valueOf(d.id)))); // update fields from device magic?
            }else{
    			this.deviceWrapperList.add(new DeviceWrapper(d));
            }
    	}

    	return null;
    }
    
    public pageReference saveDevices(){
        
        List<Device__c> deviceUpsertList = new List<Device__c>();
        
        for (DeviceWrapper dw :this.deviceWrapperList) {
            deviceUpsertList.add(dw.device);
        }
		
        try {
            upsert deviceUpsertList Device_Id__c;
        } catch (Exception e) {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error updating devices!'));
        }
        
        return null;
    }
    
    public class DeviceWrapper {
        
        public Device__c device {get;set;}
        
    	public DeviceWrapper(DeviceMagicService.Device deviceMagicDevice) {
            
			this.device = new Device__c(Device_Id__c = String.valueOf(deviceMagicDevice.id), 
                                        Description__c = deviceMagicDevice.description,
                                        Groups__c = deviceMagicDevice.groups,
                                        Identifier__c = deviceMagicDevice.identifier,
                                        Organization_Id__c = String.valueOf(deviceMagicDevice.organization_id),
                                        Owner__c = deviceMagicDevice.owner,
                                        Pending_Approval__c = deviceMagicDevice.pending_approval);
            
    	}
        
        public DeviceWrapper(Device__c device) {
			this.device = device;
    	}
    }
    
}