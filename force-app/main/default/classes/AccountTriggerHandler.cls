public class AccountTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new AccountSalespersonHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new AccountSalespersonHelper(trigger.old, trigger.new).execute();
    }
}