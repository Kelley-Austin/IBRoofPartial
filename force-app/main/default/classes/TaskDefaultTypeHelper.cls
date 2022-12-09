public class TaskDefaultTypeHelper {
    private List<Task> oldList;
    private List<Task> newList;
    
    public TaskDefaultTypeHelper(List<Task> oldList, List<Task> newList) {
    	this.oldList = (oldList == null) ? new List<Task>() : oldList;
    	this.newList = (newList == null) ? new List<Task>() : newList;
    }

    public void execute() { // before insert and before update only
        for (Task theTask : this.newList) {
            if (theTask.TaskSubtype != null && theTask.Type == null)
                theTask.Type = theTask.TaskSubtype;
        }
    }
}