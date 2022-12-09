public class HistoricalSalesTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new HistoricalSalesSageHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new HistoricalSalesSageHelper(trigger.old, trigger.new).execute();
    }
}