/**
 * Name         :   SAG100SalesorderHistoryHeaderTrigger
 * Developer    :   Kelley Austin
 * Created On   :   02/16/2022
 * Description  :   Trigger on CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c to roll up CY_Historical_Sales_2__c and 
 *                  PY_Historical_Sales_2__c on Account when Salesorder inserted, updated or deleted
 * Test Class   :   SalesorderHistoryHeaderTriggerTest
 */
trigger SAG100SalesorderHistoryHeaderTrigger on CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c (After Insert, After Update, Before Delete) {
    if(Trigger.isInsert){
        // SalesorderHistoryHeaderTriggerHandler.afterInsert(trigger.new);
        SalesorderHistoryHeaderTriggerHandler.mapStatusOnOpenSalesOrders(trigger.new, null);
    }

    if(Trigger.isUpdate){
        // SalesorderHistoryHeaderTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        SalesorderHistoryHeaderTriggerHandler.mapStatusOnOpenSalesOrders(trigger.new, trigger.oldMap);
    }

    // if(Trigger.isDelete){
    //     SalesorderHistoryHeaderTriggerHandler.beforeDelete(trigger.oldMap);
    // }
}