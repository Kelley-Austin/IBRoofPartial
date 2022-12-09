@isTest
private class GoalAccountBatchTest {
	
    static testMethod void testBatch(){
        
        SageTestFactory fact = new SageTestFactory();
        fact.createSalesperson(true, '00', '0010');
        fact.createSalesPlan(true,fact.salesperson);
        fact.createAccount(true, fact.salesperson, '00','CRM12002');
        fact.createCustomerSalesHistory(true,fact.acc,'2021','01');
        fact.createCustomerSalesHistory(true,fact.acc,'2021','02');
        fact.createCustomerSalesHistory(true,fact.acc,'2021','03');
        fact.createCustomerSalesHistory(true,fact.acc,'2021','04');

        Test.startTest();
        
        Database.executeBatch(new GoalAccountBatch(), 10);
        
        Test.stopTest();
        
    }
}