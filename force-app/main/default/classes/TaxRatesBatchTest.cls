@isTest
private class TaxRatesBatchTest {
    static testMethod void myTest() {
        Project__c[] projectList = new List<Project__c>();
        for (Integer i=0;i<10;i++) {
            Project__c project = new Project__c(Name = 'Project ' + i, Zip__c = '00000');
            projectList.add(project);
        }
        insert projectList;

        Test.startTest();

        TaxRatesBatch trb = new TaxRatesBatch();
        Database.executeBatch(trb);

        Test.stopTest();
    }
}