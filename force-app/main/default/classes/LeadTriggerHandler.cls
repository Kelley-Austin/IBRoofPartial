public class LeadTriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        new LeadTerritoryHelper(trigger.old,trigger.new).execute();
    }
    
    public override void beforeUpdate() {
        new LeadTerritoryHelper(trigger.old,trigger.new).execute();
        new LeadWordpressRepAssignHelper(trigger.old, trigger.new).executeBefore();
    }
}