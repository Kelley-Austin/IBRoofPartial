/**
 * Name         :   Sage100InvoiceTrigger
 * Developer    :   Kelley Austin
 * Created On   :   03/16/2022
 * Description  :   Trigger on CommercientSF8__AR_INVOICEHISTORYHEADER__c to roll up CY_Historical_Sales_2__c and 
 *                  PY_Historical_Sales_2__c on Account when Salesorder inserted, updated or deleted
 * Test Class   :   SalesorderHistoryHeaderTriggerTest
 */
trigger Sage100InvoiceTrigger on CommercientSF8__AR_INVOICEHISTORYHEADER__c (After Insert, After Update, Before Delete) {
    if(Trigger.isInsert){
        Sage100InvoiceHandler.afterInsert(trigger.new);
    }

    if(Trigger.isUpdate){
        Sage100InvoiceHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

    if(Trigger.isDelete){
        Sage100InvoiceHandler.beforeDelete(trigger.oldMap);
    }
}