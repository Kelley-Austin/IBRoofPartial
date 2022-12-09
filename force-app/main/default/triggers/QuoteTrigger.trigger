trigger QuoteTrigger on Quote (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	new QuoteTriggerHandler().execute();
}