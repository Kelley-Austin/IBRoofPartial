@isTest
public class AccountContractorTriggerTest {
@isTest
    public static void actt(){
        account acc = new account();
        acc.Name = 'Saif Account';
        acc.Phone = '9635883458';
        acc.Warrantied_Account_Email__c = 'ms2saif@gmail.com';
        acc.Customer_Number__c = '12345';
        acc.BillingCity = 'bgp';
        acc.BillingStreet = 'bhagalpur';
        acc.BillingState = 'bihar';
        acc.BillingPostalCode = '812001';
        insert acc;
        
        
        account acc1 = new account();
        acc1.Name = 'Saif Account1';
        acc1.Phone = '9635883450';
        acc1.Warrantied_Account_Email__c = 'ms2saif1@gmail.com';
        acc1.Customer_Number__c = '123456';
        acc1.BillingCity = 'bgpp';
        acc1.BillingStreet = 'bhpagalpur';
        acc1.BillingState = 'bihapr';
        acc1.BillingPostalCode = '81201';
        insert acc1;
        list<account> aa = [select Id from account where Id =:acc1.Id];
        delete aa;
    }
}