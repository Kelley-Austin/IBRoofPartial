@isTest
private class TaskTriggerHandlerTest {
    static testMethod void subTypeTest() {
        Task theTask = new Task(TaskSubtype = 'Email', Subject = 'test');
        insert theTask;

        theTask.Type = null;
        update theTask;
    }

    static testMethod void type2Test() {
        Task theTask = new Task(Type2__c = 'Email', Subject = 'test');
        insert theTask;

        theTask.Type = null;
        update theTask;
    }
}