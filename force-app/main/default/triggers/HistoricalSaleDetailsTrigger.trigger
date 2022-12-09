trigger HistoricalSaleDetailsTrigger on Historical_Sale_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new HistoricalSaleDetailsTriggerHandler().execute();
}