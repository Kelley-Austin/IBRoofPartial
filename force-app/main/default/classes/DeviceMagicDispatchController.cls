public class DeviceMagicDispatchController {
    
    private Opportunity opp;
    @TestVisible private Map<String, DeviceMagicService.Form> formMap;
    @TestVisible private Map<String,Device__c> deviceMap;
    
    public List<SelectOption> forms{get;set;}
	public String selectedForm {get;set;}
	
	public List<SelectOption> devices{get;set;} 
	public String selectedDevice {get;set;}
	
    public DeviceMagicDispatchController(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        this.forms = new List<SelectOption>();
        this.devices = new List<SelectOption>();
        this.formMap = new Map<String, DeviceMagicService.Form>();
        this.deviceMap = new Map<String,Device__c>();
    }
     
    public PageReference action() {
    	
    	DeviceMagicService service;
    	DeviceMagicService.FormsPayload formPayload;
    	try {
	    	service = new DeviceMagicService();
	    	formPayload = service.getFormsFromDeviceMagic();
    	} catch (Exception e) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    	system.debug('formPayload-->' + formPayload);
		for (DeviceMagicService.Form f : formPayload.forms) {
			this.forms.add(new SelectOption(String.valueOf(f.id), f.name));	 
			this.formMap.put(String.valueOf(f.id), f);
		}
		
    	
    	List<Device__c> deviceList = [SELECT Device_Id__c, Identifier__c, Owner__c, Field_Tech__r.Name, Field_Tech__r.Email, Description__c FROM Device__c WHERE Field_Tech__c != null];
    	for (Device__c device : deviceList){
            this.deviceMap.put(device.Device_Id__c, device);
        }
    	
    	DeviceMagicService.DevicesPayload devicePayload;
    	
    	try {
    		devicePayload = service.getDevicesFromDeviceMagic();
    	} catch (Exception e) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    	for (DeviceMagicService.Device d: devicePayload.devices) {
            
            if (this.deviceMap.containsKey(String.valueOf(d.id)) == true) {
            	Device__c dvc = this.deviceMap.get(String.valueOf(d.id));
            	this.devices.add(new SelectOption(dvc.Device_Id__c, dvc.Field_Tech__r.Name)); // update fields from device magic?
            }
    	}
    	
    	return null;
    } 
    
    public pageReference dispatch() {
    	
    	Device__c dvc = this.deviceMap.get(this.selectedDevice);
    	DeviceMagicService.Form form = formMap.get(this.selectedForm);
    	
    	Opportunity sourceOpp = [SELECT Id, Name FROM Opportunity WHERE Id = :this.opp.Id];
    	
    	Map<String,String> payloadMap = new Map<String,String>();
    	payloadMap.put('Email', dvc.Field_Tech__r.Email);
    	payloadMap.put('SFDC_Project_Id', sourceOpp.Id);
    	
    	FormWrapper wrap = new FormWrapper(form, payloadMap);
    	
    	DeviceMagicService service;
    	Integer result;
    	try {
    		service = new DeviceMagicService();
    		result = service.dispatchPayload(wrap, dvc.Identifier__c);
    	} catch (Exception e) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    	
    	
    	if(result != 202)
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Status Code:' + result));//Need to put a better error message
    	} else {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Form Dispatched Successfully'));
    	} 
    	
    	
    	
    	return null;
    }
    
    public PageReference cancel() {
    	
    	PageReference page = new ApexPages.StandardController(this.opp).view();
        page.setRedirect(true);
        return page;
    	
    }
    
}