/**
 * Name         :   RecalculateRollupsBatch
 * Developer    :   Kelley Austin
 * Created On   :   05/08/2022
 * Description  :   Batch class to update Recalculate_Rollups with now that will invoke the Sage100InvoiceTrigger to calculate various rollups.
 * Test class   :   RecalculateRollupsBatchTest
 */
global class RecalculateRollupsBatch implements Database.Batchable<sObject>{
    private String query = 'SELECT Id, Recalculate_Rollups__c, CommercientSF8__Account__c, Invoice_Year__c, Invoice_Month__c FROM CommercientSF8__AR_INVOICEHISTORYHEADER__c';
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('this.query : '+this.query);
        return Database.getQueryLocator(this.query);
    }
   
    public void execute(Database.BatchableContext BC, List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> scope){
        try{
            Map<String,CommercientSF8__AR_INVOICEHISTORYHEADER__c> invoiceMap = new Map<String,CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
            for(CommercientSF8__AR_INVOICEHISTORYHEADER__c invoice : scope){
                // invoiceMap.put(invoice.CommercientSF8__Account__c + '-' + invoice.Invoice_Year__c + '-' + invoice.Invoice_Month__c,new CommercientSF8__AR_INVOICEHISTORYHEADER__c(Id = invoice.Id,Recalculate_Rollups__c = System.now()));
                invoiceMap.put(invoice.CommercientSF8__Account__c,new CommercientSF8__AR_INVOICEHISTORYHEADER__c(Id = invoice.Id,Recalculate_Rollups__c = System.now()));
            }
            update invoiceMap.values();
        }catch(Exception e){
            System.debug('#### ERROR : '+e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC){}
}