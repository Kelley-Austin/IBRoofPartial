public class InspectionTriggerHandler extends TriggerHandler{
	public override void beforeInsert() {
		new InspectionTriggerHelper(trigger.old,trigger.new).execute();
	}
}