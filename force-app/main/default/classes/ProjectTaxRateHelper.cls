public class ProjectTaxRateHelper {
    private List<Project__c> oldList;
    private List<Project__c> newList;
    
    public ProjectTaxRateHelper(List<Project__c> oldList, List<Project__c> newList) {
    	this.oldList = (oldList == null) ? new List<Project__c>() : oldList;
    	this.newList = (newList == null) ? new List<Project__c>() : newList;
    }

    public void executeBeforeUpdate() {
        for (Project__c project : this.newList) {
            Project__c oldProject = (Project__c) Trigger.oldMap.get(project.Id);
            if (project.Zip__c == null || project.Zip__c != oldProject.Zip__c) {
                project.Tax_Rate__c = null;
                project.Tax_Rate_Updated_At__c = null;
            }
        }
    }
}