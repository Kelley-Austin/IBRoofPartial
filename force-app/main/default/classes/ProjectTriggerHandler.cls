public class ProjectTriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        new ProjectTaxRateHelper(Trigger.old, Trigger.new).executeBeforeUpdate();
    }
}