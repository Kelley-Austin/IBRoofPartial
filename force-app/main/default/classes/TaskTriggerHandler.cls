public class TaskTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        new TaskDefaultTypeHelper(Trigger.old, Trigger.new).execute();
        new TaskType2Helper(Trigger.old, Trigger.new).execute();
    }

    public override void beforeUpdate() {
        new TaskDefaultTypeHelper(Trigger.old, Trigger.new).execute();
        new TaskType2Helper(Trigger.old, Trigger.new).execute();
    }
}