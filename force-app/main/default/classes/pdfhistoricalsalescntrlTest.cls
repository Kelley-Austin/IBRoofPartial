@isTest
public class pdfhistoricalsalescntrlTest {
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
        
        Historical_Sales__c o=new Historical_Sales__c();
        o.Name = 'test';
        o.Customer_Account__c = a.Id;
        o.Invoice_Number__c = '123412';
        o.External_Id__c = '1111';
        insert o;
        
        Historical_Sale_Details__c ol = new Historical_Sale_Details__c();
        ol.Name = 'test';
        ol.Historical_Sales__c = o.Id;
        ol.Invoice_Order_Detail__c = '1122334';
        insert ol;
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        pdfhistoricalsalescntrl hcl=new pdfhistoricalsalescntrl(sc);
        
        
    }
    
}