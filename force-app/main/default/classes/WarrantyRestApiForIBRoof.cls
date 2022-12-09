global with sharing class WarrantyRestApiForIBRoof {
    @future(callout=true)
    global static void WarrantyUpdateDate(Id warrantyId){
        string request_string = 'data=' + EncodingUtil.urlEncode(getWarrantyData(warrantyId), 'UTF-8');
        system.debug('Request Json String:::::: '+ request_string);
        Http http1=new Http();
        HttpRequest req1=new HttpRequest();
        //https://uat.ibroof.com/update_pdf_salesforce.php
        //https://ibroof.com/update_pdf_salesforce.php
        req1.setendpoint('https://ibroof.com/update_pdf_salesforce.php');
        req1.setmethod('POST'); 
        req1.setbody(request_string);
        HttpResponse res1;
        res1 = http1.send(req1);
        String response_string =res1.getbody();
        system.debug('sendCSATData Response Json String::: ' + response_string);
    }
    global static string getWarrantyData(Id warrantyId){
        string returnjson;
        string warrantytype;
        list<Warranty__c> wr = [SELECT Id, Name, Project_Name_Bldg__c,Warrantied_Account__c, Roofing_Company__c, Project__c, Warranty_Type__c, Warranty_Length__c, Warranty_Start_Date__c, IB_Sales_Rep__c, Related_Invoice__c, Invoice_Date__c, Warranty_Number_Legacy__c, Original_Owner_Legacy__c, Primary_Building_Use__c, Issuance_Date__c, Invoice_Number__c, Contractor_s_PO_Number__c, Duration__c, Cost_per_Sq_Ft__c, Invoice_Warranty_Cost__c, Coverage__c, Warranty_Expiration_Date__c, Quoted_Warranty_Fee__c, Paid__c, Transfer_Date__c, Transfer_Amount__c, Transfer_Fee_Received__c, Stage__c, Job_Type__c, Active_Project__c, NOA_Received_Date__c, Technical_Start_Date__c, Technical_Completion_Date__c, Tech_Status__c, Warranty_Status__c, NOA_Approved_Date__c, Reviewed_By__c, Edit__c, Same_As_Owner_Address__c, Warrantied_Account_Copy__c, Roofing_Company_Copy__c, Company_Name__c, Warranty_Certification__c, Fastener_del__c, Warranty_Account_Email__c, Roofing_Company_Email__c, Warranty_Origin__c, Warranty_Physical_City__c, Warranty_Physical_Country__c, Warranty_Physical_State__c, Warranty_Physical_Street__c, Warranty_Physical_ZipCode__c, FM_Insured__c, Insulation_MFG__c, Insulation_Type__c, Insulation_Thickness__c, Insulation_Layers__c, Field_Fast__c, Warranty_Number__c, Original_Owner__c, Transfer_Status__c, Membrane_Type__c, Membrane_Color__c, Roof_Size__c, Membrane_Thickness__c, Type_of_Structure__c, Transfer_Owner__c, Building_Type__c, Transfer_Inspection_Date__c, Separation_Sheet__c, Roof_System__c, Adhesive_Type__c, Plates__c, Deck_Type__c, Perimeter__c, Corner__c, PVC_Clad_Metal__c, Other_Building_Use__c, Project_Address__c, Project_City__c, Project_State__c, Project_Zip_Code__c, Project_Name__c, Project_Phone_Number__c, Field_Tech__c, Installation_Address__c, Installation_City__c, Installation_State__c, Installation_ZipCode__c, Project_Email__c,Roofing_Company__r.Phone FROM Warranty__c Where Id =: warrantyId];
        if(wr.size()>0){
            if(wr[0].Warranty_Type__c == 'Material Only (Residential & Commercial)'){
               warrantytype = 'Material Only (Residential Commercial)';
            }else{
               warrantytype =  wr[0].Warranty_Type__c;
            }
            returnjson = '{'+'"WarrantyID"'+':'+'"'+wr[0].Name+'"'+','+'"WarrantyType"'+':'+'"'+warrantytype+'"'+','+'"WarrantyNumber"'+':'+'"'+wr[0].Warranty_Number__c+'"'+','+'"WarrantyLength"'+':'+'"'+wr[0].Warranty_Length__c+'"'+','+'"IssuanceDate"'+':'+'"'+wr[0].Issuance_Date__c+'"'+','+'"WarrantyStartInstallationDate"'+':'+'"'+wr[0].Warranty_Start_Date__c+'"'+','+'"WarrantyExpirationDate"'+':'+'"'+wr[0].Warranty_Expiration_Date__c+'"'+','+'"BuildingType"'+':'+'"'+wr[0].Building_Type__c+'"'+','+'"WarrantyOrigin"'+':'+'"'+wr[0].Warranty_Origin__c+'"'+','+'"Stage"'+':'+'"'+wr[0].Stage__c+'"'+','+'"BuildingOwnerCompanyName"'+':'+'"'+wr[0].Company_Name__c+'"'+','+'"ProjectName"'+':'+'"'+wr[0].Project_Name__c+'"'+','+'"ProjectAddress"'+':'+'"'+wr[0].Project_Address__c+'"'+','+'"ProjectState"'+':'+'"'+wr[0].Project_State__c+'"'+','+'"ProjectPhone"'+':'+'"'+wr[0].Project_Phone_Number__c+'"'+','+'"ProjectEmail"'+':'+'"'+wr[0].Project_Email__c+'"'+','+'"SameasWarrantyAccountowner"'+':'+'"'+wr[0].Same_As_Owner_Address__c+'"'+','+'"ProjectCity"'+':'+'"'+wr[0].Project_City__c+'"'+','+'"ProjectZipCode"'+':'+'"'+wr[0].Project_Zip_Code__c+'"'+','+'"InstallationAddress"'+':'+'"'+wr[0].Installation_Address__c+'"'+','+'"InstallationCity"'+':'+'"'+wr[0].Installation_City__c+'"'+','+'"InstallationState"'+':'+'"'+wr[0].Installation_State__c+'"'+','+'"InstallationZipCode"'+':'+'"'+wr[0].Installation_ZipCode__c+'"'+','+'"PrimaryBuildingUse"'+':'+'"'+wr[0].Primary_Building_Use__c+'"'+','+'"JobType"'+':'+'"'+wr[0].Job_Type__c+'"'+','+'"MembraneType"'+':'+'"'+wr[0].Membrane_Type__c+'"'+','+'"MembraneColor"'+':'+'"'+wr[0].Membrane_Color__c+'"'+','+'"TypeofStructure"'+':'+'"'+wr[0].Type_of_Structure__c+'"'+','+'"RoofSizetotalsqft"'+':'+'"'+wr[0].Roof_Size__c+'"'+','+'"MembraneThickness"'+':'+'"'+wr[0].Membrane_Thickness__c+'"'+','+'"ProjectNameBldg"'+':'+'"'+wr[0].Project_Name_Bldg__c+'"'+','+'"RoofingCompanyPhone"'+':'+'"'+wr[0].Roofing_Company__r.Phone+'"'+'}';
        }else{
            returnjson = 'no record found';
        }
        return returnjson;
    }
}