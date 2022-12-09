trigger FulfillmentTrigger on Fulfillment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new FulfillmentTriggerHandler().execute();
}