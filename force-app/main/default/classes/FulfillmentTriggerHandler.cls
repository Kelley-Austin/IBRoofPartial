public class FulfillmentTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new FulfillmentSageHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new FulfillmentSageHelper(trigger.old, trigger.new).execute();
    }
}