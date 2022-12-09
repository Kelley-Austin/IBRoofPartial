@isTest
private class SageTriggerHandlerTest {
    
    static testMethod void testSalesperson(){
        
        SageTestFactory factory = new SageTestFactory();
        
        Test.startTest();

        Salesperson__c salesperson = factory.createSalesperson(true, '00', '0012');

        update salesperson;

        Test.stopTest();
    }
    
    static testMethod void testAccount(){
        
        SageTestFactory factory = new SageTestFactory();
        
        factory.createSalesperson(true, '00', '0012');
        
        Test.startTest();
        
        Account account = factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        update account;
        
        Test.stopTest();
    }

    static testMethod void testContact(){
        
        SageTestFactory factory = new SageTestFactory();
        
        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        Test.startTest();
        
        Contact contact = factory.createContact(true, factory.acc, 'TEST');
        
        update contact;
        
        Test.stopTest();
    }

    static testMethod void testFulfillment(){
        
        SageTestFactory factory = new SageTestFactory();

        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        Test.startTest();
        
        Fulfillment__c fulfillment = factory.createFulfillment(true, factory.acc, '52020');
        
        update fulfillment;

        FulfillmentSageHelper.parseType('S');
        FulfillmentSageHelper.parseType('B');
        FulfillmentSageHelper.parseType('M');
        FulfillmentSageHelper.parseType('R');
        FulfillmentSageHelper.parseType('Q');
        FulfillmentSageHelper.parseType('P');
        FulfillmentSageHelper.parseType('None');
        FulfillmentSageHelper.parseType(null);

        FulfillmentSageHelper.parseStatus('N');
        FulfillmentSageHelper.parseStatus('O');
        FulfillmentSageHelper.parseStatus('C');
        FulfillmentSageHelper.parseStatus('H');
        FulfillmentSageHelper.parseStatus('Z');
        FulfillmentSageHelper.parseStatus('None');
        FulfillmentSageHelper.parseStatus(null);

        FulfillmentSageHelper.parseDecimal('0.25');
        FulfillmentSageHelper.parseDecimal('None');
        FulfillmentSageHelper.parseDecimal(null);
        
        FulfillmentSageHelper.parseDate('2020-01-01');
        FulfillmentSageHelper.parseDate('None');
        FulfillmentSageHelper.parseDate(null);
        
        Test.stopTest();
    }

    static testMethod void testCustomerSalesHistory(){
        
        SageTestFactory factory = new SageTestFactory();

        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        Test.startTest();
        
        Customer_Sales_History__c customerSalesHistory = factory.createCustomerSalesHistory(true, factory.acc, '2020', '01');
        
        update customerSalesHistory;
        
        Test.stopTest();
    }

    static testMethod void testHistoricalSales(){
        
        SageTestFactory factory = new SageTestFactory();

        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        Test.startTest();
        
        Historical_Sales__c historicalSales = factory.createHistoricalSales(true, factory.acc, '36849', '000000');
        
        update historicalSales;
        
        Test.stopTest();
    }

    static testMethod void testHistoricalSaleDetails(){
        
        SageTestFactory factory = new SageTestFactory();

        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');

        factory.createHistoricalSales(true, factory.acc, '0036849', '000000');
        
        Test.startTest();
        
        Historical_Sale_Details__c historicalSaleDetails = factory.createHistoricalSaleDetails(true, factory.historicalSales, '000000');
        
        update historicalSaleDetails;
        
        Test.stopTest();
    }

    static testMethod void testOpenInvoice(){
        
        SageTestFactory factory = new SageTestFactory();

        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        Test.startTest();
        
        Open_Invoice__c openInvoice = factory.createOpenInvoice(true, factory.acc, '36849', '000000');
        
        update openInvoice;
        
        Test.stopTest();
    }

    static testMethod void testDailyShipment() {
        SageTestFactory factory = new SageTestFactory();

        factory.createSalesperson(true, '00', '0012');

        factory.createAccount(true, factory.salesperson, '00', 'JGA042');
        
        Test.startTest();
        
        DailyShipment__c dailyShipment = factory.createDailyShipment(true, factory.acc, '51069');
        
        update dailyShipment;
        
        Test.stopTest();
    }
}