/**
 * Name         :   Sage100InvoiceTriggerTest
 * Developer    :   Kelley Austin
 * Created On   :   02/16/2022
 * Description  :   Test class for Sage100InvoiceHandler
 */
@isTest
private class Sage100InvoiceHandlerTest {
    static testMethod void testAfterInsert(){
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;

        List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
        for(Integer i = 1 ; i <= 50 ; i++){
            CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder1 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
            salesOrder1.CommercientSF8__Account__c = acc1.Id;
            salesOrder1.CommercientSF8__InvoiceDate__c = System.today().addMonths(math.mod(i, 5));
            salesOrder1.CommercientSF8__TAXABLESALESAMT__c = 100;
            salesOrder1.CommercientSF8__CUSTOMERNO__c = '12345';
            salesOrder1.CommercientSF8__ExternalKey__c = '12345990' + String.ValueOf(i);
            salesOrderList.add(salesOrder1);
        }

        for(Integer i = 1 ; i <= 50 ; i++){
            CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder2 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
            salesOrder2.CommercientSF8__Account__c = acc1.Id;
            salesOrder2.CommercientSF8__InvoiceDate__c = System.today().addYears(-1).addMonths(math.mod(i, 5));
            salesOrder2.CommercientSF8__TAXABLESALESAMT__c = 100;
            salesOrder2.CommercientSF8__CUSTOMERNO__c = '12346';
            salesOrder2.CommercientSF8__ExternalKey__c = '1234599000' + String.ValueOf(i);
            salesOrderList.add(salesOrder2);
        }
        
        //Test insert new SALESORDERHISTORYHEADER
        test.startTest();
            insert salesOrderList;
        test.stopTest();
        System.assertEquals(5000,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        System.assertEquals(5000,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
        System.assert([SELECT Most_Recent_Sage100_Invoice__c FROM Account WHERE Id =: acc1.Id].Most_Recent_Sage100_Invoice__c != null);
    }

    static testMethod void testAfterUpdate(){
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;

        Account acc2 = new Account(Name = 'test acc 2');
        insert acc2;

        List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
        
        for(Integer i = 1 ; i <= 50 ; i++){
            CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder1 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
            salesOrder1.CommercientSF8__Account__c = acc1.Id;
            salesOrder1.CommercientSF8__InvoiceDate__c = System.today().addMonths(math.mod(i, 5));
            salesOrder1.CommercientSF8__TAXABLESALESAMT__c = 100;
            salesOrder1.CommercientSF8__CUSTOMERNO__c = '12345';
            salesOrder1.CommercientSF8__ExternalKey__c = '1234590' + String.ValueOf(i);
            salesOrderList.add(salesOrder1);
        }

        for(Integer i = 1 ; i <= 50 ; i++){
            CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder2 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
            salesOrder2.CommercientSF8__Account__c = acc1.Id;
            salesOrder2.CommercientSF8__InvoiceDate__c = System.today().addYears(-1).addMonths(math.mod(i, 5));
            salesOrder2.CommercientSF8__TAXABLESALESAMT__c = 100;
            salesOrder2.CommercientSF8__CUSTOMERNO__c = '12345';
            salesOrder2.CommercientSF8__ExternalKey__c = '123459900000' + String.ValueOf(i);
            salesOrderList.add(salesOrder2);
        }

        insert salesOrderList;

        System.assertEquals(5000,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        System.assertEquals(5000,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);

        //Test update SALESORDERHISTORYHEADER with account and Invoice total changed
        test.startTest();
            for(CommercientSF8__AR_INVOICEHISTORYHEADER__c so : salesOrderList){
                so.CommercientSF8__Account__c = acc2.Id;
	            so.CommercientSF8__TAXABLESALESAMT__c = 200;
            }
            update salesOrderList;
        test.stopTest();
        System.assertEquals(0,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        System.assertEquals(0,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
        System.assertEquals(10000,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc2.Id].PY_Historical_Sales_2__c);
        System.assertEquals(10000,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc2.Id].CY_Historical_Sales_2__c);
        System.assert([SELECT Most_Recent_Sage100_Invoice__c FROM Account WHERE Id =: acc2.Id].Most_Recent_Sage100_Invoice__c != null);
    }
    
    static testMethod void testAfterUpdateLASTINVOICEDATE(){
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;

        List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
        for(Integer i = 1 ; i <= 100 ; i++){
            CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder1 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
            salesOrder1.CommercientSF8__Account__c = acc1.Id;
            salesOrder1.CommercientSF8__CUSTOMERNO__c = '12345';
            salesOrder1.CommercientSF8__ARDIVISIONNO__c = '00';
            salesOrder1.CommercientSF8__InvoiceDate__c = System.today().addMonths(math.mod(i, 5));
            salesOrder1.CommercientSF8__TAXABLESALESAMT__c = 100;
            salesOrder1.CommercientSF8__ExternalKey__c = '12345000990' + String.ValueOf(i);
            salesOrderList.add(salesOrder1);
        }
        
        insert salesOrderList;

        //Test update SALESORDERHISTORYHEADER with CommercientSF8__InvoiceDate__c changed
        test.startTest();
        	for(CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder : salesOrderList){
				salesOrder.CommercientSF8__InvoiceDate__c = salesOrder.CommercientSF8__InvoiceDate__c.addMonths(1);
            }
            update salesOrderList;
        test.stopTest();
    }

    static testMethod void testBeforeDelete(){
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;

        List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
        CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder1 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
        salesOrder1.CommercientSF8__Account__c = acc1.Id;
        salesOrder1.CommercientSF8__InvoiceDate__c = System.today();
        salesOrder1.CommercientSF8__TAXABLESALESAMT__c = 100;
        salesOrder1.CommercientSF8__ExternalKey__c = '34599000000';
        salesOrderList.add(salesOrder1);

        CommercientSF8__AR_INVOICEHISTORYHEADER__c salesOrder2 = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
        salesOrder2.CommercientSF8__Account__c = acc1.Id;
        salesOrder2.CommercientSF8__InvoiceDate__c = System.today().addYears(-1);
        salesOrder2.CommercientSF8__TAXABLESALESAMT__c = 100;
            salesOrder2.CommercientSF8__ExternalKey__c = '1234000000000';
        salesOrderList.add(salesOrder2);

        insert salesOrderList;
        System.assertEquals(100,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        System.assertEquals(100,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);

        // Test delete SALESORDERHISTORYHEADER
        test.startTest();
            delete salesOrderList;
        test.stopTest();
        System.assertEquals(0,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        System.assertEquals(0,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
        System.assert([SELECT Most_Recent_Sage100_Invoice__c FROM Account WHERE Id =: acc1.Id].Most_Recent_Sage100_Invoice__c == null);
    }
}