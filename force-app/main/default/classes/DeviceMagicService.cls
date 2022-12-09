public class DeviceMagicService {
    
    private String baseUrl;
    private String apiToken;
    static final String PASSWORD = 'x';
    
    public DeviceMagicService() {
    	Device_Magic__c dm = Device_Magic__c.getOrgDefaults();
    	if (dm.API_Token__c == null) {
    		throw new DeviceMagicException('Add API Token to custom settings');
    	}
    	
    	if (dm.Base_URL__c == null) {
    		throw new DeviceMagicException('Add API Token to custom settings');
    	}
    	this.baseUrl = dm.Base_URL__c;
    	this.apiToken = dm.API_Token__c;
    }
    
    public DevicesPayload getDevicesFromDeviceMagic() {
    	
    	String auth = EncodingUtil.base64Encode(Blob.valueOf(this.apiToken +':'+ PASSWORD));	
    	 
    	Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(this.baseUrl + '/devices.json');
		req.setHeader('Authorization','Basic ' + auth);
		req.setMethod('GET'); 
		HttpResponse res = h.send(req);
		
		String jsonString = res.getBody();
		DevicesPayload deviceList;
		
		if(res.getStatusCode() != 200) {
			throw new DeviceMagicException('Device Magic Call Failed' + res.getBody());
		}
		
		try {
			deviceList = (DevicesPayload) System.JSON.deserialize(jsonString, DevicesPayload.class);
		} catch (Exception e) {
			throw new DeviceMagicException(e.getMessage());
		}
		
		return deviceList;
    }
    
    
    
    public FormsPayload  getFormsFromDeviceMagic() {
    	
    	String auth = EncodingUtil.base64Encode(Blob.valueOf(this.apiToken +':'+ PASSWORD));	
    	 
    	Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(this.baseUrl + '/forms.json');
		req.setHeader('Authorization','Basic ' + auth);
		req.setMethod('GET'); 
		HttpResponse res = h.send(req);
		
		String jsonString = res.getBody();
		FormsPayload payload;
		
		if(res.getStatusCode() != 200) {
			throw new DeviceMagicException('Device Magic Call Failed' + res.getBody());
		}
		
		
		try {
			payload = parseFormsPayload(jsonString);
		} catch (Exception e) {
			throw new DeviceMagicException(e.getMessage());
		}
		
		return payload;
    }
    
    public Integer dispatchPayload( FormWrapper form, String deviceIdentifier) {
    	
    	String auth = EncodingUtil.base64Encode(Blob.valueOf(this.apiToken +':'+ PASSWORD));
    	
    	Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://www.devicemagic.com/clients/' + deviceIdentifier + '/oneshots');
		req.setHeader('Authorization','Basic ' + auth);
		req.setHeader('Content-Type','application/json');
		req.setMethod('POST');
		req.setBody(JSON.serialize(form)); 
		HttpResponse res = h.send(req);
		
		String jsonString = res.getBody();
		
		
		return res.getStatusCode();
    }
    
    public static FormsPayload parseFormsPayload(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new FormsPayload(parser);
	}
	
	private static List<Form> arrayOfForms(System.JSONParser p) {
        List<Form> res = new List<Form>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Form(p)); 
        }
        return res; 
    }
    
    public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
    
    public class DeviceMagicException extends Exception {}
    
    public class DevicesPayload {
    	public List<Device> devices;
    }
    
    public class Device {
    	
		public Integer id;
		public String identifier;
		public Integer organization_id;
		public String owner;
		public String description;
		public Boolean pending_approval;
		public String groups;
		//public Custom_attributes custom_attributes
	}
	
	public class FormsPayload {
		public List<Form> forms;
		
		public FormsPayload(JSONParser parser) {
			
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'forms') {
							forms = arrayOfForms(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
		
		
	}
	
	public class Form {
		public Integer id; 
		public String name; 
		public String namespace; 
		public String version; 
		public String description; 
		public String group_Z; // test this and see if its needed
		
		public Form(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'namespace') {
							namespace = parser.getText();
						} else if (text == 'version') {
							version = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'group') {
							group_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Forms consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
}