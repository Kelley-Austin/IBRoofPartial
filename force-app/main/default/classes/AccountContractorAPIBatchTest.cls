@isTest
private class AccountContractorAPIBatchTest {
    static testMethod void myTest() {
        List<account> lacc = new List<account>();
        account acc = new account();
        acc.Name = 'Saif Account';
        acc.Phone = '9635883458';
        acc.Warrantied_Account_Email__c = 'ms2saif@gmail.com';
        acc.Customer_Number__c = '12345';
        acc.BillingCity = 'bgp';
        acc.BillingStreet = 'bhagalpur';
        acc.BillingState = 'bihar';
        acc.BillingPostalCode = '812001';
        lacc.add(acc);
        account acc1 = new account();
        acc1.Name = 'Saif Account1';
        acc1.Phone = '9635883450';
        acc1.Warrantied_Account_Email__c = 'ms2saif1@gmail.com';
        acc1.Customer_Number__c = '123456';
        acc1.BillingCity = 'bgpp';
        acc1.BillingStreet = 'bhpagalpur';
        acc1.BillingState = 'bihapr';
        acc1.BillingPostalCode = '81201';
        lacc.add(acc1);
        insert lacc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        AccountContractorAPIBatch batch = new AccountContractorAPIBatch();
        Database.executeBatch(batch);

        Test.stopTest();
    }
}