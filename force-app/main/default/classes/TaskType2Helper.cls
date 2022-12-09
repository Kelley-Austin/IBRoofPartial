public class TaskType2Helper {
    private List<Task> oldList;
    private List<Task> newList;
    
    public TaskType2Helper(List<Task> oldList, List<Task> newList) {
    	this.oldList = (oldList == null) ? new List<Task>() : oldList;
    	this.newList = (newList == null) ? new List<Task>() : newList;
    }

    public void execute() { // before insert and before update only
        for (Task theTask : this.newList) {
            if (theTask.Type2__c != null && theTask.Type == null)
                theTask.Type = theTask.Type2__c;
        }
    }
}