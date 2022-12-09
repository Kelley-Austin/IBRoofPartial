public class InspectionTriggerHelper {
    private List<Inspection__c> oldList;
    private List<Inspection__c> newList;
    
    public InspectionTriggerHelper (List<Inspection__c> oldList, List<Inspection__c> newList) {
    	this.oldList = (oldList == null) ? new List<Inspection__c>() : oldList;
    	this.newList = (newList == null) ? new List<Inspection__c>() : newList;
    }
    
    public void execute() {
    	
    	Set<String> projectNames = new Set<String>();
    	Set<String> warrantyNos = new Set<String>();
    	Set<String> contractors = new Set<String>();
    	Set<String> inspectorNames = new Set<String>();
    	Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Inspection__c.getRecordTypeInfosByName();
    	
    	Set<String> formNames = new Set<String>();
    	Map<String, Device_Magic_Inspection_RecordType__c> dmSettingsMap = Device_Magic_Inspection_RecordType__c.getAll();
    	
    	for(Inspection__c i : this.newList) {
    		projectNames.add(i.Dispatched_Project_Name__c);
    		warrantyNos.add(i.Warranty_No__c);
    		contractors.add(i.Contractor__c);
    		inspectorNames.add(i.Inspected_By_Text__c);
    		formNames.add(i.Device_Magic_Form_Name__c);
    	}
    	 
    	projectNames.remove(null);
    	warrantyNos.remove(null);
    	contractors.remove(null);
    	inspectorNames.remove(null);
    	formNames.remove(null);
    	
    	List<Opportunity> projectList = [SELECT Id,Name FROM Opportunity WHERE Name IN :projectNames];
    	List<Warranty__c> warrantyList = [SELECT Id,Name FROM Warranty__c WHERE Name IN :warrantyNos];
    	List<Account> contractorList = [SELECT Id,Customer_Number__c FROM Account WHERE Customer_Number__c IN :contractors];
    	List<User> inspectorList = [SELECT Id, CommunityNickname FROM User WHERE CommunityNickname IN :inspectorNames];    	
    	
    	Map<String, Id> projectMap = new Map<String, Id>();
    	
    	for (Opportunity o: projectList) {
    		projectMap.put(o.Name,o.Id);
    	}
    	
    	Map <String, Id> warrantyMap = new Map<String, Id>();
    	
    	for (Warranty__c w: warrantyList) {
    		warrantyMap.put(w.Name,w.Id);
    	}
    	
    	Map<String, Id> contractorMap = new Map<String, Id>();
    	
    	for (Account a: contractorList) {
    		contractorMap.put(a.Customer_Number__c, a.Id);
    	}
    	
    	Map<String, Id> inspectorMap = new Map<String, Id>();
    	
    	for (User u: inspectorList) {
    		inspectorMap.put(u.CommunityNickname, u.Id);
    	}
    	
    	for (Inspection__c i: this.newList) {
    		
    		if (projectMap.containsKey(i.Dispatched_Project_Name__c) && i.Inspected_Project__c == null) {
    			i.Inspected_Project__c = projectMap.get(i.Dispatched_Project_Name__c);
    		}
    		
    		if (warrantyMap.containsKey(i.Warranty_No__c) && i.Warranty__c == null) {
    			i.Warranty__c = warrantyMap.get(i.Warranty_No__c);
    		}
    		
    		if (contractorMap.containsKey(i.Contractor__c) && i.Contractor_Account__c == null) {
    			i.Contractor_Account__c = contractorMap.get(i.Contractor__c);
    		}
    		
    		if (inspectorMap.containsKey(i.Inspected_By_Text__c) && i.Inspected_By_User__c == null) {
    			i.Inspected_By_User__c = inspectorMap.get(i.Inspected_By_Text__c);
    		}
    		
    		if (dmSettingsMap.containsKey(i.Device_Magic_Form_Name__c) == true && recordTypeMap.containsKey(dmSettingsMap.get(i.Device_Magic_Form_Name__c).Record_Type_Name__c)) {
    			i.RecordTypeId = recordTypeMap.get(dmSettingsMap.get(i.Device_Magic_Form_Name__c).Record_Type_Name__c).getRecordTypeId();
    		} 
    		
    	}
    	
    }
}