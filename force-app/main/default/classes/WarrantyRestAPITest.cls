@isTest
public class WarrantyRestAPITest {
    public static testMethod void wrat(){
       // WarrantyRestAPI.createWarranty();
       string msg = WarrantyRestAPI.createWarranty(
            '1','doh', 'Phone', 'sushant@gmail.com','digiture','digiture@gmail.com','D','','04/06/2019','','04/06/2019','14/06/2019','Residential','Complete',true,'IBroof','Mumbai','Maharastra','8108456517','Navi Mumbai','400701','Yes','Developer','M','red','Jad','12ft sq','wakad tikad','Deploma');
        string msg1 = WarrantyRestAPI.updateWarranty('1','Mumbai', 'Mumbai','Maharashtra','123456','sushant@gmail.com','abcde');
        // Verify results
       // System.assert(msg != null);
        //Case thisCase = [SELECT Id,Subject FROM Case WHERE Id=:thisCaseId];
        //System.assert(thisCase != null);
       // System.assertEquals(thisCase.Subject, 'Ferocious chipmunk');
    }
}