trigger InspectionTrigger on Inspection__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new InspectionTriggerHandler().execute();
}