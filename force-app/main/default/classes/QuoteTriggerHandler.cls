public class QuoteTriggerHandler extends TriggerHandler {
	
    public override void afterInsert() {
    	new QuoteAccountHelper(Trigger.old,Trigger.new).execute();
    }
    
    public override void afterUpdate() {
    	new QuoteAccountHelper(Trigger.old,Trigger.new).execute();
    }
    
    
}