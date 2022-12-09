trigger CustomerSalesHistoryTrigger on Customer_Sales_History__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new CustomerSalesHistoryTriggerHandler().execute();   
}