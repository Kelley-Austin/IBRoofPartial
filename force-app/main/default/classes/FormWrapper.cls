public class FormWrapper {
    	
	public String form_namespace;
	public Payload payload;
	
	public FormWrapper(DeviceMagicService.Form form, Map<String,String> payloadMap) {
		this.form_namespace = form.namespace;
		this.payload = new Payload(payloadMap);
	}

    
    public class Payload {
	   	
	   	public String Email;
    	public String SFDC_Project_Id;
    	
    	public Payload(Map<String,String> payloadMap) {
    		
    		if(payloadMap.containsKey('Email') ) {
    			this.Email = payloadMap.get('Email');	
    		}
    		
    		if(payloadMap.containsKey('SFDC_Project_Id')) {
    			this.SFDC_Project_Id = payloadMap.get('SFDC_Project_Id');
    		}
    		
    	}
	}    
}