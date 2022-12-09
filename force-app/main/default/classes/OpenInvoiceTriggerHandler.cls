public class OpenInvoiceTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new OpenInvoiceSageHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new OpenInvoiceSageHelper(trigger.old, trigger.new).execute();
    }
}