trigger OpenInvoiceTrigger on Open_Invoice__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new OpenInvoiceTriggerHandler().execute();
}