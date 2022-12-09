trigger WarrantyAccountCheck on Warranty__c (before insert,after update) {
    if(Trigger.isInsert){
        for(Warranty__c  w : trigger.new){
            // account wacc;
            //account cacc;
            Id PaccId;
            if(w.Roofing_Company_Copy__c != null){
                list<account> cacc = [select Id,Warrantied_Account_Email__c from account where Name =: w.Roofing_Company_Copy__c limit 1]; 
                list<RecordType> rt = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType ='Account' and Name = 'Business Account']; 
                if(cacc.size() > 0 && w.Roofing_Company_Copy__c != null){
                    w.Roofing_Company__c= cacc[0].Id;
                    w.Roofing_Company_Email__c = cacc[0].Warrantied_Account_Email__c;
                    // PaccId = cacc[0].Id;
                }else{
                    account a1 = new account();
                    a1.Name = w.Roofing_Company_Copy__c;
                    a1.Warrantied_Account_Email__c = w.Roofing_Company_Email__c;
                    a1.RecordTypeId = rt[0].Id;
                    try{
                        insert a1;
                        PaccId = a1.Id;
                    }catch(Exception e1){
                        system.debug('Error Message1 '+e1.getMessage()); 
                    }        
                    w.Roofing_Company__c = a1.Id;
                }
            }
            if(w.Warrantied_Account_Copy__c != null){
                list<account> wacc = [select Id,Warrantied_Account_Email__c from account where Name =: w.Warrantied_Account_Copy__c and Warrantied_Account_Email__c =: w.Warranty_Account_Email__c limit 1];
                list<RecordType> rt1 = [SELECT Id, Name, SobjectType FROM RecordType where SobjectType ='Account' and Name = 'Warrantied Account']; 
                if(wacc.size() >0 && w.Warrantied_Account_Copy__c != null){
                    w.Warrantied_Account__c = wacc[0].Id;
                    w.Warranty_Account_Email__c = wacc[0].Warrantied_Account_Email__c;
                }else{
                    account a = new account();
                    a.Name = w.Warrantied_Account_Copy__c;
                    a.Warrantied_Account_Email__c = w.Warranty_Account_Email__c;
                    a.RecordTypeId = rt1[0].Id;
                    a.Phone = w.Project_Phone_Number__c;
                    a.BillingStreet = w.Project_Address__c;
                    a.BillingCity = w.Project_City__c;
                    a.BillingState = w.Project_State__c;
                    a.BillingPostalCode = w.Project_Zip_Code__c;
                    a.Building_Owner_Company_Name__c = w.Company_Name__c;
                    if(PaccId != null){
                        a.ParentId = PaccId;  
                    }
                    try{
                        insert a;  
                    }catch(Exception e){
                        system.debug('Error Message '+e.getMessage()); 
                    }        
                    w.Warrantied_Account__c = a.Id;
                }
            }
            // System.debug(wacc+'====='+cacc);
        }  
    }
    if(Trigger.isUpdate){
        for(Warranty__c  w : trigger.new){
            WarrantyRestApiForIBRoof.WarrantyUpdateDate(w.Id); 
        }
    }
}