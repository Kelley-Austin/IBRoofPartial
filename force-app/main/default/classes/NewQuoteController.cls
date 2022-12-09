/**
* Name         : NewQuoteController
* Description  : Apex controller for newQuote lightning web component
* Author       : Kelley Austin
* Created On   : 10/13/2021
*/
public with sharing class NewQuoteController {
    /**
* Name         : getAccountDetails
* Description  : Method to return Account details based on account Id
* Param 1      : Id accId - Account record Id
* Return       : Map of String and Account Name
*/
    @AuraEnabled
    public static Map<String, Object> getAccountDetails(Id accId){
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<Account> acc = [SELECT Id, Name FROM Account WHERE Id =: accId];
            if(acc.size() > 0){
                result.put('result', acc[0].Name);
            }
        } catch (Exception e) {
            result.put('error', 'Server Side Apex Error ##...' + e.getMessage());
        }
        return result;
    }
    
    /**
* Name         : getLocalTaxRates
* Description  : Method to invoke Avalara TAx API to get local tax rate based on ZIP code selected by user
* Param 1      : quoteRec - Quote Object record
* Return       : Map of String and ProjectData class
*/
    @AuraEnabled
    public static Map<String, Object> getLocalTaxRates(Quote quoteRec){
        System.debug('getLocalTaxRates - quoteRec :: ' + quoteRec);
        Map<String, Object> result = new Map<String, Object>();
        try{
            AvalaraTaxRatesAPIService.TaxResponse taxResponse = AvalaraTaxRatesAPIService.getTaxRates(String.valueOf(quoteRec.Shipping_Zip_Postal_Code__c), 'US');
            system.debug('#### taxResponse : '+taxResponse);
            String taxResponseSerialized = JSON.serialize(taxResponse);
            projectData pd = new projectData(taxResponseSerialized, quoteRec.Shipping_Zip_Postal_Code__c +' '+quoteRec.Shipping_Country__c);
            result.put('result', pd);
        }catch(Exception e){
            result.put('error', 'Server Side Apex Error ##...' + e.getMessage());
        }
        return result;
    }
    
    @InvocableMethod(callout=true label='Update Quote' description='Calculate Local Tax if ship to postal code gets changed.' category= 'Quote')
    public static void updateQuoteWithLocalTax(List<Id> quoteId){
        System.debug('Id :: ' + quoteId);
        List<Quote> quote = [SELECT id,Local_Tax_Rate__c, ShippingPostalCode FROM Quote WHERE id=:quoteId];
        if(quote[0].ShippingPostalCode!=null){
            NewQuoteController.getLocatTaxCallout(String.valueOf(quote[0].ShippingPostalCode), quoteId);
        }else{
            quote[0].Local_Tax_Rate__c = 0.00;
            update quote[0];
        }
    }
    
    @future(callout=true)
    public static void getLocatTaxCallout(String postalCode, List<Id> quoteId){
        Decimal localTax;
        if(postalCode!=null){
            System.debug('postal code :: ' + postalCode);
            try{
                AvalaraTaxRatesAPIService.TaxResponse taxResponse = AvalaraTaxRatesAPIService.getTaxRates(String.valueOf(postalCode), 'US');
                String taxResponseSerialized = JSON.serialize(taxResponse);
                TaxRateWrapper trW = (TaxRateWrapper)JSON.deserialize(taxResponseSerialized, TaxRateWrapper.class);
                System.debug('tax rate $$$$ ' + trW.totalRate);
                localTax = trW.totalRate*100;
                List<Quote> quote = [SELECT id,Local_Tax_Rate__c, ShippingPostalCode FROM Quote WHERE id=:quoteId];
                quote[0].Local_Tax_Rate__c = localTax;
                update quote[0];
            }catch(Exception e){
                System.debug('error $$$$ ' + e.getMessage());
                //result.put('error', 'Server Side Apex Error ##...' + e.getMessage());
            }
        }
    }
    
    
    /**
* Name         : getProjectDetails
* Description  : Method to return Project details based on project Id
* Param 1      : Id recId - Project record Id
* Return       : Map of String and ProjectData class
*/
    // @AuraEnabled
    // public static Map<String, Object> getProjectDetails(Id recId){
    //     System.debug('recId :: ' + recId);
    //     Map<String, Object> result = new Map<String, Object>();
    //     try{
    //         List<Project__c> projectList = [SELECT Id, Name, Tax_Rate__c, Street__c, City__c, State__c, Zip__c, Country__c
    //                                         FROM Project__c WHERE Id =: recId];
    //         System.debug('projectList :: ' + projectList);
    //         if(projectList.size() > 0){
    //             String taxRate = String.isNotBlank(projectList[0].Tax_Rate__c) ? (projectList[0].Tax_Rate__c) : '';
    //             String shippingAdd = '';
    //             shippingAdd += String.isNotBlank(projectList[0].Street__c) ? (projectList[0].Street__c + ', ') : '';
    //             shippingAdd += String.isNotBlank(projectList[0].City__c) ? (projectList[0].City__c + ', ') : '';
    //             shippingAdd += String.isNotBlank(projectList[0].State__c) ? (projectList[0].State__c + ', ') : '';
    //             shippingAdd += String.isNotBlank(projectList[0].Zip__c) ? (projectList[0].Zip__c + ', ') : '';
    //             shippingAdd += String.isNotBlank(projectList[0].Country__c) ? (projectList[0].Country__c) : '';
    //             projectData pd = new projectData(taxRate, shippingAdd);
    //             result.put('result', pd);
    //             result.put('projectDetails', projectList[0]);
    //         }else{
    //             result.put('error', 'No Project details found.');
    //         }
    //     }catch(Exception e){
    //         result.put('error', 'Server Side Apex Error ##...' + e.getMessage());
    //     }
    //     return result;
    // }
    
    /**
* Name         : saveNewQuote
* Description  : Method invoked on Save Quote button to create Quote and Opportunity records
* Param 1      : Id accId - Account record Id
* Param 1      : Id projectId - Project record Id
* Return       : Map of String and Account Name
*/
    @AuraEnabled
    public static Map<String, Object> saveNewQuote(Quote quoteRec, string fileName, String base64Data) {
        system.debug('#### quoteRec : '+quoteRec);
        // system.debug('#### fileName : '+fileName);
        // system.debug('#### fileContent : '+base64Data);
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try{
            Opportunity opp =  new Opportunity(Name = quoteRec.Name,
                                               CloseDate = Date.today().addDays(14), // should this be user input?
                                               Project__c = quoteRec.Project2__c,
                                               AccountId = quoteRec.AccountId,
                                               StageName = 'Estimating');
            insert opp;
            
            List<PricebookEntry> pbeList = [SELECT Id, Pricebook2Id
                                            FROM PricebookEntry 
                                            WHERE Pricebook2.IsStandard = true
                                            AND IsActive=true];
            
            quoteRec.OpportunityId = opp.Id;
            quoteRec.Pricebook2Id = pbeList[0].Pricebook2Id;
            quoteRec.ExpirationDate = Date.today().addMonths(1);
            insert quoteRec;
            system.debug('#### New Quote Id : '+ quoteRec.Id);
            
            if(fileName != null && fileName != '' && base64Data != null && base64Data != ''){
                base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = EncodingUtil.base64Decode(base64Data);
                cv.Title = fileName;
                cv.PathOnClient = filename;
                insert cv;
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = quoteRec.Id;
                cdl.ShareType = 'V';
                insert cdl;
            }
            
            result.put('result', 'Quote created succefully');
            result.put('quoteId', quoteRec.Id);
        }catch(Exception e){
            result.put('error', 'Server Side Apex Error ##...' + e.getMessage());
            Database.rollback(sp);
        }
        return result;
    }
    
    public class TaxRateWrapper{
        public Decimal totalRate{get;set;}
    }
    
    public class ProjectData{
        @AuraEnabled
        public String taxRate{get;set;}
        @AuraEnabled
        public String shippingAdd{get;set;}
        
        public ProjectData(String taxRate, String shippingAdd){
            this.taxRate = taxRate;
            this.shippingAdd = shippingAdd;
        }
    }
}