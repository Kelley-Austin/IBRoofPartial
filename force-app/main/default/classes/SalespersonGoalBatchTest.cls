@isTest
private class SalespersonGoalBatchTest {
    
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
        
        Database.executeBatch(new SalespersonGoalBatch(), 100);
        
        Test.stopTest();

        
        
    }
    static testMethod void testBatchSchedule(){
        Test.startTest();
        System.schedule('SalespersonGoalBatchHourlytest', '0 0 * * * ?', new SalespersonGoalBatch());
        Test.stopTest();
    }
    static testMethod void testBatchStaticMethods(){
        
        SageTestFactory fact = new SageTestFactory();
        fact.createSalesperson(true, '00', '0010');
        fact.createSalesPlan(true,fact.salesperson);
        
        Test.startTest();
        
        for (Integer i = 0; i < 12 ; i++){
            SalespersonGoalBatch.monthGoal(fact.salesPlan, Date.today().addMonths(i));
            SalespersonGoalBatch.monthQuota(fact.salesPlan, Date.today().addMonths(i));
            
			SalespersonGoalBatch.quarterQuota(fact.salesPlan, Date.today().addMonths(i));
			SalespersonGoalBatch.quarterGoal(fact.salesPlan, Date.today().addMonths(i));
               
        }
        

        Test.stopTest();
    }

}