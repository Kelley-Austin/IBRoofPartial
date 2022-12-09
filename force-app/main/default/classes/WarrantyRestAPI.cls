@RestResource(urlMapping='/warrantyform/*')
global with sharing class WarrantyRestAPI {
    //https://test-ibroofsystem.cs65.force.com/services/apexrest/warrantyform/
    //http://ibroofsystems.force.com/warranty/services/apexrest/warrantyform/
    //Date.parse() – accepts date string in MM/DD/YYYY format.
    //Date.valueOf() – accepts date string in YYYY-MM-dd format.
    /*@HttpGet
global static Account doGet() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];
return result;
}*/
    @HttpPost
    global static string createWarranty(String WarrantyId, String warrantyaccount, string warrantyaccountemail,
                                        String roofingcompany, String roofingcompanyemail, string WarrantyType, string WarrantyLength,
                                        string WarrantyStartDate, string WarrantyNumber,string IssuanceDate,string WarrantyExpirationDate,
                                        string BuildingType,string Stage,string BuildingOwnerCompanyName,boolean SameAsOwnerAddress,
                                        string ProjectName,string ProjectAddress,string ProjectState,string ProjectPhoneNumber,string ProjectCity,
                                        string ProjectZipCode,string PrimaryBuildingUse,string JobType,string MembraneType,string MembraneColor,
                                        string MembraneThickness,string RoofSize,string TypeofStructure,string WarrantyCertification) {
                                            //Warranty__c InstallationAddress, Warranty__c,Project_Email__c, Installation_Address__c, Installation_City__c,Installation_State__c, Installation_ZipCode__c
                                            // 'ProjectEmail':'value', 'InstallationAddress':'({"Installation_Address__c":"value","Installation_City__c":"value","Installation_State__c":"value","Installation_ZipCode__c":"value"})' 
                                            System.debug('BuildingOwnerCompanyName ===> '+BuildingOwnerCompanyName);
                                            string WarrantyAccountPhone;
                                            string WarrantyPhysicalAddress;
                                            string WarrantyPhysicalCity;
                                            string WarrantyPhysicalState;
                                            string WarrantyPhysicalZipCode;
                                            string WarrantyPhysicalCountry;
                                            list<RecordType> rt = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType  = 'Warranty__c' and Name = 'Materials Only'];
                                            Warranty__c w = new Warranty__c();
                                            w.Name = WarrantyId;
                                            w.RecordTypeId = rt[0].Id;
                                            w.Warranty_Origin__c = 'Web';
                                            /* if(WarrantyAccountPhone != '' || WarrantyAccountPhone != null ){
w.Warranty_Account_Phone__c = WarrantyAccountPhone;
}
if(WarrantyPhysicalAddress != '' || WarrantyPhysicalAddress != null ){
w.Warranty_Physical_Street__c = WarrantyPhysicalAddress;
}
if(WarrantyPhysicalCity != '' || WarrantyPhysicalCity != null ){
w.Warranty_Physical_City__c = WarrantyPhysicalCity;
}
if(WarrantyPhysicalState != '' || WarrantyPhysicalState != null ){
w.Warranty_Physical_State__c = WarrantyPhysicalState;
}
if(WarrantyPhysicalZipCode != '' || WarrantyPhysicalZipCode != null ){
w.Warranty_Physical_ZipCode__c = WarrantyPhysicalZipCode;
}
if(WarrantyPhysicalCountry != '' || WarrantyPhysicalCountry != null ){
w.Warranty_Physical_Country__c = WarrantyPhysicalCountry;
}*/
                                            if(warrantyaccount != '' || warrantyaccount != null ){
                                                w.Warrantied_Account_Copy__c = warrantyaccount;
                                            }
                                            if(warrantyaccountemail != '' || warrantyaccountemail != null ){
                                                w.Warranty_Account_Email__c = warrantyaccountemail; 
                                            }
                                            if(roofingcompanyemail != '' || roofingcompanyemail != null ){
                                                w.Roofing_Company_Email__c = roofingcompanyemail; 
                                            }
                                            if(roofingcompany != '' || roofingcompany != null ){
                                                w.Roofing_Company_Copy__c = roofingcompany;
                                            }
                                            if(WarrantyType != '' || WarrantyType != null ){
                                                w.Warranty_Type__c = WarrantyType;
                                            }
                                            if(WarrantyLength != '' || WarrantyLength != null ){
                                                w.Warranty_Length__c = WarrantyLength;
                                            }
                                            if(WarrantyStartDate != '' ){
                                                w.Warranty_Start_Date__c = Date.parse(WarrantyStartDate);
                                            }
                                            if(WarrantyNumber != '' || WarrantyNumber != null ){
                                                w.Warranty_Number__c = WarrantyNumber;  
                                            }
                                            if(IssuanceDate != ''){
                                                w.Issuance_Date__c = Date.parse(IssuanceDate);
                                            }
                                            if(WarrantyExpirationDate != ''){
                                                w.Warranty_Expiration_Date__c = Date.parse(WarrantyExpirationDate);
                                            }
                                            if(BuildingType != '' || BuildingType != null ){
                                                w.Building_Type__c = BuildingType; 
                                            }
                                            if(Stage != ''){
                                                w.Stage__c = Stage; 
                                            }
                                            if(BuildingOwnerCompanyName != ''){
                                                w.Company_Name__c = BuildingOwnerCompanyName;
                                            }
                                            if(SameAsOwnerAddress == true ){
                                                w.Same_As_Owner_Address__c = SameAsOwnerAddress;
                                            }else{
                                                w.Same_As_Owner_Address__c = false;
                                            }
                                            if(ProjectName != '' || ProjectName != null ){
                                                w.Project_Name__c = ProjectName;
                                            }
                                            if(ProjectAddress != '' || ProjectAddress != null ){
                                                w.Project_Address__c = ProjectAddress;                                             
                                            }
                                            if(ProjectState != '' || ProjectState != null ){
                                                w.Project_State__c = ProjectState; 
                                            }
                                            if(ProjectPhoneNumber != '' || ProjectPhoneNumber != null ){
                                                w.Project_Phone_Number__c = ProjectPhoneNumber;
                                            }
                                            if(ProjectCity != '' || ProjectCity != null ){
                                                w.Project_City__c = ProjectCity;
                                            }
                                            if(ProjectZipCode != '' || ProjectZipCode != null ){
                                                w.Project_Zip_Code__c = ProjectZipCode;
                                            }
                                            if(PrimaryBuildingUse != '' || PrimaryBuildingUse != null ){
                                                w.Primary_Building_Use__c = PrimaryBuildingUse;
                                            }
                                            if(JobType != '' || JobType != null ){
                                                w.Job_Type__c = JobType;
                                            }
                                            if(MembraneType != '' || MembraneType != null ){
                                                w.Membrane_Type__c = MembraneType;  
                                            }
                                            if(MembraneColor != '' || MembraneColor != null ){
                                                w.Membrane_Color__c = MembraneColor;
                                            }
                                            if(MembraneThickness != '' || MembraneThickness != null ){
                                                w.Membrane_Thickness__c = MembraneThickness;
                                            }
                                            if(RoofSize != '' || RoofSize != null ){
                                                w.Roof_Size__c = RoofSize;
                                            }
                                            if(TypeofStructure != '' || TypeofStructure != null ){
                                                w.Type_of_Structure__c = TypeofStructure;
                                            }
                                            if(WarrantyCertification != '' || WarrantyCertification != null ){
                                                w.Warranty_Certification__c = WarrantyCertification;
                                            }
                                            
                                            try{
                                                insert w; 
                                            }catch(Exception e){
                                                System.debug('Error Message W '+e.getMessage()); 
                                            }
                                            
                                            return 'success';
                                        } 
    @HttpPatch
    global static string updateWarranty(string WarrantyId,string InstallationAddress,string InstallationCity,string InstallationState,string InstallationZipCode,string ProjectEmail,string ProjectNameBldg){
        string ret;
        List<Warranty__c> wt = [select Name,Installation_Address__c,Installation_City__c,Installation_State__c,Installation_ZipCode__c,Project_Email__c,IsUpdate__c,Project_Name_Bldg__c from Warranty__c where Name =: WarrantyId];
        if(wt.size()>0){
            wt[0].Installation_Address__c = InstallationAddress;
            wt[0].Installation_City__c = InstallationCity;
            wt[0].Installation_State__c = InstallationState;
            wt[0].Installation_ZipCode__c = InstallationZipCode;
            wt[0].Project_Email__c = ProjectEmail;
        	wt[0].IsUpdate__c = true;
            wt[0].Project_Name_Bldg__c = ProjectNameBldg;
        try{
            update wt;
            ret = 'updated';
        }catch(Exception exe){
            System.debug('Error Message '+exe.getMessage());
            ret = 'error';
        }
        }
    else{
        ret='record id not found';
    }
    return ret;
}    
}