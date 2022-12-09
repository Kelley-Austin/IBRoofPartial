public class DailyShipmentTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new DailyShipmentSageHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new DailyShipmentSageHelper(trigger.old, trigger.new).execute();
    }
}