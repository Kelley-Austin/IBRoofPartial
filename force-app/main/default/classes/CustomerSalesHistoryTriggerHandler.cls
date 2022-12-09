public class CustomerSalesHistoryTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
    	new CustomerSalesHistoryAccountHelper(trigger.old,trigger.new).execute();
    }

    public override void beforeUpdate() {
        new CustomerSalesHistoryAccountHelper(trigger.old, trigger.new).execute();
    }
}