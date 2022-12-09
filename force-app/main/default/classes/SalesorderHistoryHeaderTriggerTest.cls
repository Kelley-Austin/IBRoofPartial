/**
 * Name         :   SalesorderHistoryHeaderTriggerTest
 * Developer    :   Kelley Austin
 * Created On   :   02/16/2022
 * Description  :   Test class for SalesorderHistoryHeaderTrigger
 */
@isTest
private class SalesorderHistoryHeaderTriggerTest {
    static testMethod void testAfterInsert(){
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;

        CommercientSF8__SO_SALESORDERHEADER__c openOrder = new CommercientSF8__SO_SALESORDERHEADER__c();
        openOrder.CommercientSF8__Account__c = acc1.Id;
        openOrder.Name = '12345';
        openOrder.CommercientSF8__SALESORDERNO__c = '12345';
        insert openOrder;

        List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c>();
        CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder1 = new CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c();
        salesOrder1.CommercientSF8__Account__c = acc1.Id;
        salesOrder1.CommercientSF8__LASTINVOICEDATE__c = System.today();
        salesOrder1.CommercientSF8__TAXABLEAMT__c = 100;
        salesOrder1.CommercientSF8__CUSTOMERNO__c = '12345';
        salesOrder1.CommercientSF8__ORDERSTATUS__c = 'C';
        salesOrder1.Name = '12345';
        salesOrderList.add(salesOrder1);

        CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder2 = new CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c();
        salesOrder2.CommercientSF8__Account__c = acc1.Id;
        salesOrder2.CommercientSF8__LASTINVOICEDATE__c = System.today().addYears(-1);
        salesOrder2.CommercientSF8__TAXABLEAMT__c = 100;
        salesOrder2.CommercientSF8__CUSTOMERNO__c = '12346';
        salesOrder2.CommercientSF8__ORDERSTATUS__c = 'C';
        salesOrder2.Name = '12346';
        salesOrderList.add(salesOrder2);

        //Test insert new SALESORDERHISTORYHEADER
        test.startTest();
            insert salesOrderList;
        test.stopTest();
        // System.assertEquals(100,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        // System.assertEquals(100,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
        System.assertEquals('C',[SELECT Related_History_Header_Orderstatus__c FROM CommercientSF8__SO_SALESORDERHEADER__c WHERE Id =: openOrder.Id].Related_History_Header_Orderstatus__c);
    }

    static testMethod void testAfterUpdate(){
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;

        Account acc2 = new Account(Name = 'test acc 2');
        insert acc2;

        CommercientSF8__SO_SALESORDERHEADER__c openOrder = new CommercientSF8__SO_SALESORDERHEADER__c();
        openOrder.CommercientSF8__Account__c = acc1.Id;
        openOrder.Name = '12345';
        openOrder.CommercientSF8__SALESORDERNO__c = '12345';
        insert openOrder;

        List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c>();
        CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder1 = new CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c();
        salesOrder1.CommercientSF8__Account__c = acc1.Id;
        salesOrder1.CommercientSF8__LASTINVOICEDATE__c = System.today();
        salesOrder1.CommercientSF8__TAXABLEAMT__c = 100;
        salesOrder1.Name = '12345';
        salesOrder1.CommercientSF8__ORDERSTATUS__c = 'C';
        salesOrderList.add(salesOrder1);

        CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder2 = new CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c();
        salesOrder2.CommercientSF8__Account__c = acc1.Id;
        salesOrder2.CommercientSF8__LASTINVOICEDATE__c = System.today().addYears(-1);
        salesOrder2.CommercientSF8__TAXABLEAMT__c = 100;
        salesOrder2.Name = '12346';
        salesOrder2.CommercientSF8__ORDERSTATUS__c = 'C';
        salesOrderList.add(salesOrder2);

        insert salesOrderList;

        // System.assertEquals(100,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        // System.assertEquals(100,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
        System.assertEquals('C',[SELECT Related_History_Header_Orderstatus__c FROM CommercientSF8__SO_SALESORDERHEADER__c WHERE Id =: openOrder.Id].Related_History_Header_Orderstatus__c);

        //Test update SALESORDERHISTORYHEADER with account and Invoice total changed
        test.startTest();
            // salesOrderList[0].CommercientSF8__Account__c = acc2.Id;
            // salesOrderList[1].CommercientSF8__Account__c = acc2.Id;
            // salesOrderList[0].CommercientSF8__TAXABLEAMT__c = 200;
            // salesOrderList[1].CommercientSF8__TAXABLEAMT__c = 200;

            salesOrderList[0].CommercientSF8__ORDERSTATUS__c = 'X';
            salesOrderList[1].CommercientSF8__ORDERSTATUS__c = 'X';
            update salesOrderList;
        test.stopTest();
        // System.assertEquals(0,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
        // System.assertEquals(0,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
        // System.assertEquals(200,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc2.Id].PY_Historical_Sales_2__c);
        // System.assertEquals(200,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc2.Id].CY_Historical_Sales_2__c);
        System.assertEquals('X',[SELECT Related_History_Header_Orderstatus__c FROM CommercientSF8__SO_SALESORDERHEADER__c WHERE Id =: openOrder.Id].Related_History_Header_Orderstatus__c);
    }

    // static testMethod void testBeforeDelete(){
    //     Account acc1 = new Account(Name = 'test acc 1');
    //     insert acc1;

    //     List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c> salesOrderList = new List<CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c>();
    //     CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder1 = new CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c();
    //     salesOrder1.CommercientSF8__Account__c = acc1.Id;
    //     salesOrder1.CommercientSF8__LASTINVOICEDATE__c = System.today();
    //     salesOrder1.CommercientSF8__TAXABLEAMT__c = 100;
    //     salesOrderList.add(salesOrder1);

    //     CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c salesOrder2 = new CommercientSF8__SAGE100_SALESORDERHISTORYHEADER__c();
    //     salesOrder2.CommercientSF8__Account__c = acc1.Id;
    //     salesOrder2.CommercientSF8__LASTINVOICEDATE__c = System.today().addYears(-1);
    //     salesOrder2.CommercientSF8__TAXABLEAMT__c = 100;
    //     salesOrderList.add(salesOrder2);

    //     insert salesOrderList;
    //     System.assertEquals(100,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
    //     System.assertEquals(100,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);

    //     // Test delete SALESORDERHISTORYHEADER
    //     test.startTest();
    //         delete salesOrderList;
    //     test.stopTest();
    //     System.assertEquals(0,[SELECT PY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].PY_Historical_Sales_2__c);
    //     System.assertEquals(0,[SELECT CY_Historical_Sales_2__c FROM Account WHERE Id =: acc1.Id].CY_Historical_Sales_2__c);
    // }
}