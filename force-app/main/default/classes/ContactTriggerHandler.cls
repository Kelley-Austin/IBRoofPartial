public class ContactTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new ContactSageHelper(trigger.old, trigger.new).executeBeforeInsert();
        new ContactSageHelper(trigger.old, trigger.new).execute();
    }

    public override void beforeUpdate() {
        new ContactSageHelper(trigger.old, trigger.new).execute();
    }
}