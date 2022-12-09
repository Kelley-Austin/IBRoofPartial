@isTest
private class AccountRegionBatchTest {
    static testMethod void myTest() {
        
        Zipcode_Territory__c zt = new Zipcode_Territory__c(Zip_Code__c = '12345', Territory_Number__c = '001');
		insert zt;
        
        Account acc = new Account(Name = 'test test', ShippingPostalCode = '12345', BillingPostalCode = '12345');
        insert acc;

        Test.startTest();

        AccountRegionBatch batch = new AccountRegionBatch();
        Database.executeBatch(batch);

        Test.stopTest();
    }
}