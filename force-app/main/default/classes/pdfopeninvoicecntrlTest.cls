@isTest
public class pdfopeninvoicecntrlTest {
    static testMethod void orderMethod(){
        Account a=new Account();
        a.Name='Ramya';
        a.Phone = '9635883458';
        a.BillingCity = 'Mumbai';
        a.BillingState= 'Maharashtra';
        a.BillingPostalCode = '400069';
        a.BillingCountry = 'India';
        a.BillingStreet = 'Mumabi';
       insert a;
        
        Open_Invoice__c o = new Open_Invoice__c();
        o.External_Id__c = '123456';
        o.CustomerNo__c = a.Id;
        o.Name = '1111';
        insert o;
        
        Open_Invoice_Details__c	 ol = new Open_Invoice_Details__c	();
        ol.Open_Invoice_Detail__c = '123123';
        ol.Name = 'test';
        ol.Open_Invoice__c = o.Id;
        insert ol;
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        pdfopeninvoicecntrl oinv =new pdfopeninvoicecntrl(sc);
        
        
    }
    
}