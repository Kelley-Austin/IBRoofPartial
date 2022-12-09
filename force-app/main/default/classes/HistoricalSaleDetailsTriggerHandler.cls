public class HistoricalSaleDetailsTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new HistoricalSaleDetailsSageHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new HistoricalSaleDetailsSageHelper(trigger.old, trigger.new).execute();
    }
}