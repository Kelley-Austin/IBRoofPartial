trigger HistoricalSalesTrigger on Historical_Sales__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new HistoricalSalesTriggerHandler().execute();
}