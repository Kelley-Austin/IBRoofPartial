@isTest
public class WarrantyAccountCheckTest {
    @isTest
    public static void wac(){
        Warranty__c w = new Warranty__c();
        w.Warranty_Number__c = '123456';
        w.Name = '1234567890';
        w.Warrantied_Account_Copy__c = 'Test';
        w.Roofing_Company_Copy__c = 'Saif';
        insert w;
    }
}