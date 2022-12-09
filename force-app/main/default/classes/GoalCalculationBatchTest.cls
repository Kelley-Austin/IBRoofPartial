@isTest
private class GoalCalculationBatchTest {
    
    static testMethod void testBatch(){
        String currentYear = String.valueOf(System.today().year());
 		SageTestFactory fact = new SageTestFactory();
        fact.createSalesperson(true, '00', '0010');
        fact.createSalesPlan(true,fact.salesperson);
        fact.createAccount(true, fact.salesperson, '00','CRM12002');
        fact.createCustomerSalesHistory(true,fact.acc,currentYear,'01');
        fact.createCustomerSalesHistory(true,fact.acc,currentYear,'02');
        fact.createCustomerSalesHistory(true,fact.acc,currentYear,'03');
        fact.createCustomerSalesHistory(true,fact.acc,currentYear,'04');
		
        Goal__c goal = new Goal__c(External_Id__c = '00-1234',
                                           Name = '1234',
                                           Actual_MTD_Sales__c = 0,
                                           X_YTD_Sales__c = 0,
                                           Actual_QTD_Sales__c = 0);
        insert goal;
        Test.startTest();
        
        Database.executeBatch(new GoalCalculationBatch(), 200); 
        
        Test.stopTest();
    }

}