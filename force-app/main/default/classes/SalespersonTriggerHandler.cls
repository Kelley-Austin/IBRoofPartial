public class SalespersonTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new SalespersonUserHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new SalespersonUserHelper(trigger.old, trigger.new).execute();
    }
}