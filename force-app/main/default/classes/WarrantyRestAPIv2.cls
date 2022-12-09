@RestResource(urlMapping='/warrantyformv2/*')
global with sharing class WarrantyRestAPIv2 {
    //https://test-ibroofsystem.cs65.force.com/services/apexrest/warrantyform/
    //http://ibroofsystems.force.com/warranty/services/apexrest/warrantyform/
    //Date.parse() – accepts date string in MM/DD/YYYY format.
    //Date.valueOf() – accepts date string in YYYY-MM-dd format.

    @HttpPost
    global static void createWarranty() {

        System.debug('hit create warranty endpoint v2!');

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        WarrantyData warranty;

        try {
            warranty = (WarrantyData) JSON.deserialize(req.requestBody.toString(), WarrantyData.class);
        } catch (Exception e) {
            System.debug(e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(e.getMessage());
            return;
        }
 
        list<RecordType> rt = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType  = 'Warranty__c' and Name = 'Materials Only'];
        Warranty__c w = new Warranty__c();
        w.Name = warranty.WarrantyId;
        w.RecordTypeId = rt[0].Id;
        w.Warranty_Origin__c = 'Web';

        if(warranty.warrantyaccount != '' || warranty.warrantyaccount != null ){
            w.Warrantied_Account_Copy__c = warranty.warrantyaccount;
        }
        if(warranty.warrantyaccountemail != '' || warranty.warrantyaccountemail != null ){
            w.Warranty_Account_Email__c = warranty.warrantyaccountemail; 
        }
        if(warranty.roofingcompanyemail != '' || warranty.roofingcompanyemail != null ){
            w.Roofing_Company_Email__c = warranty.roofingcompanyemail; 
        }
        if(warranty.roofingcompany != '' || warranty.roofingcompany != null ){
            w.Roofing_Company_Copy__c = warranty.roofingcompany;
        }
        if(warranty.WarrantyType != '' || warranty.WarrantyType != null ){
            w.Warranty_Type__c = warranty.WarrantyType;
        }
        if(warranty.WarrantyLength != '' || warranty.WarrantyLength != null ){
            w.Warranty_Length__c = warranty.WarrantyLength;
        }
        if(warranty.WarrantyStartDate != '' ){
            w.Warranty_Start_Date__c = Date.parse(warranty.WarrantyStartDate);
        }
        if(warranty.WarrantyNumber != '' || warranty.WarrantyNumber != null ){
            w.Warranty_Number__c = warranty.WarrantyNumber;  
        }
        if(warranty.IssuanceDate != ''){
            w.Issuance_Date__c = Date.parse(warranty.IssuanceDate);
        }
        if(warranty.WarrantyExpirationDate != ''){
            w.Warranty_Expiration_Date__c = Date.parse(warranty.WarrantyExpirationDate);
        }
        if(warranty.BuildingType != '' || warranty.BuildingType != null ){
            w.Building_Type__c = warranty.BuildingType; 
        }
        if(warranty.Stage != ''){
            w.Stage__c = warranty.Stage; 
        }
        if(warranty.BuildingOwnerCompanyName != ''){
            w.Company_Name__c = warranty.BuildingOwnerCompanyName;
        }
        if(warranty.SameAsOwnerAddress == true ){
            w.Same_As_Owner_Address__c = warranty.SameAsOwnerAddress;
        }else{
            w.Same_As_Owner_Address__c = false;
        }
        if(warranty.ProjectName != '' || warranty.ProjectName != null ){
            w.Project_Name__c = warranty.ProjectName;
        }
        if(warranty.ProjectAddress != '' || warranty.ProjectAddress != null ){
            w.Project_Address__c = warranty.ProjectAddress;                                             
        }
        if(warranty.ProjectState != '' || warranty.ProjectState != null ){
            w.Project_State__c = warranty.ProjectState; 
        }
        if(warranty.ProjectPhoneNumber != '' || warranty.ProjectPhoneNumber != null ){
            w.Project_Phone_Number__c = warranty.ProjectPhoneNumber;
        }
        if(warranty.ProjectCity != '' || warranty.ProjectCity != null ){
            w.Project_City__c = warranty.ProjectCity;
        }
        if(warranty.ProjectZipCode != '' || warranty.ProjectZipCode != null ){
            w.Project_Zip_Code__c = warranty.ProjectZipCode;
        }
        if(warranty.PrimaryBuildingUse != '' || warranty.PrimaryBuildingUse != null ){
            w.Primary_Building_Use__c = warranty.PrimaryBuildingUse;
        }
        if(warranty.JobType != '' || warranty.JobType != null ){
            w.Job_Type__c = warranty.JobType;
        }
        if(warranty.MembraneType != '' || warranty.MembraneType != null ){
            w.Membrane_Type__c = warranty.MembraneType;  
        }
        if(warranty.MembraneColor != '' || warranty.MembraneColor != null ){
            w.Membrane_Color__c = warranty.MembraneColor;
        }
        if(warranty.MembraneThickness != '' || warranty.MembraneThickness != null ){
            w.Membrane_Thickness__c = warranty.MembraneThickness;
        }
        if(warranty.RoofSize != '' || warranty.RoofSize != null ){
            w.Roof_Size__c = warranty.RoofSize;
        }
        if(warranty.TypeofStructure != '' || warranty.TypeofStructure != null ){
            w.Type_of_Structure__c = warranty.TypeofStructure;
        }
        if(warranty.WarrantyCertification != '' || warranty.WarrantyCertification != null ){
            w.Warranty_Certification__c = warranty.WarrantyCertification;
        }

        if (warranty.InstallationAddress != '' || warranty.InstallationAddress != null) {
            w.Installation_Address__c = warranty.InstallationAddress;
        }
        
        if (warranty.InstallationCity != '' || warranty.InstallationCity != null) {
            w.Installation_City__c = warranty.InstallationCity;
        }
        
        if (warranty.InstallationState != '' || warranty.InstallationState != null) {
            w.Installation_State__c = warranty.InstallationState;
        }

        if (warranty.InstallationZipCode != '' || warranty.InstallationZipCode != null) {
            w.Installation_ZipCode__c = warranty.InstallationZipCode;
        }

        if (warranty.ProjectEmail != '' || warranty.ProjectEmail != null) {
            w.Project_Email__c = warranty.ProjectEmail;
        }

        if (warranty.ProjectNameBldg != '' || warranty.ProjectNameBldg != null) {
            w.Project_Name_Bldg__c = warranty.ProjectNameBldg;
        }
        
        try{
            insert w;
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('success');
        }catch(Exception e){
            System.debug('Error Message W '+e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    public class WarrantyData {
        public String WarrantyId; 
        public String warrantyaccount; 
        public String warrantyaccountemail;
        public String roofingcompany; 
        public String roofingcompanyemail; 
        public String WarrantyType; 
        public String WarrantyLength;
        public String WarrantyStartDate; 
        public String WarrantyNumber;
        public String IssuanceDate;
        public String WarrantyExpirationDate;
        public String BuildingType;
        public String Stage;
        public String BuildingOwnerCompanyName;
        public Boolean SameAsOwnerAddress;
        public String ProjectName;
        public String ProjectAddress;
        public String ProjectState;
        public String ProjectPhoneNumber;
        public String ProjectCity;
        public String ProjectZipCode;
        public String PrimaryBuildingUse;
        public String JobType;
        public String MembraneType;
        public String MembraneColor;
        public String MembraneThickness;
        public String RoofSize;
        public String TypeofStructure;
        public String WarrantyCertification;
        public String InstallationAddress;
        public String InstallationCity;
        public String InstallationState;
        public String InstallationZipCode;
        public String ProjectEmail;
        public String ProjectNameBldg;
    }
}