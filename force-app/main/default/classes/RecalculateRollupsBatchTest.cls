/**
 * Name         :   RecalculateRollupsBatchTest
 * Developer    :   Kelley Austin
 * Created On   :   05/08/2022
 * Description  :   Test class for RecalculateRollupsBatch
 * Test class   :   RecalculateRollupsBatchTest
 */
@isTest
private class RecalculateRollupsBatchTest {
    @testSetup static void setup() {
        Account acc1 = new Account(Name = 'test acc 1');
        insert acc1;
        
        List<CommercientSF8__AR_INVOICEHISTORYHEADER__c> invoiceList = new List<CommercientSF8__AR_INVOICEHISTORYHEADER__c>();
        for(Integer i = 1 ; i <= 10 ; i++){
            CommercientSF8__AR_INVOICEHISTORYHEADER__c invoice = new CommercientSF8__AR_INVOICEHISTORYHEADER__c();
            invoice.CommercientSF8__Account__c = acc1.Id;
            //invoice.CommercientSF8__InvoiceDate__c = System.today().addMonths(math.mod(i, 5));
            invoice.CommercientSF8__InvoiceDate__c = System.today().addMonths(-1);
            invoice.CommercientSF8__TAXABLESALESAMT__c = 100;
            invoice.CommercientSF8__CUSTOMERNO__c = '12345';
            invoice.CommercientSF8__ExternalKey__c = '12345990' + String.ValueOf(i);
            invoice.CommercientSF8__ARDIVISIONNO__c = '00';
            invoiceList.add(invoice);
        }
        insert invoiceList;
    }
    static testMethod void testExecute(){
        test.startTest();
        database.executeBatch(new RecalculateRollupsBatch());
        test.stopTest();
    }
}