@isTest
private class ProjectTriggerHandlerTest {
    static testMethod void myTest() {
        Project__c project = new Project__c();
        insert project;

        project.Zip__c = '95758';
        update project;
    }
}