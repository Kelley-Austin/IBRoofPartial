@isTest
private class SageUtilityTest {
	
    static testMethod void testUtility(){
        
        
        Test.startTest();
        
         //date
		SageUtility.parseDate('2017-03-24');
        
        // decimal
		SageUtility.parseDecimal('8193.00');
        
		// email
 		SageUtility.parseEmail('seth.childs@ibroof.com');
        
        Test.stopTest();
        
    }
    
    static testMethod void testUtilityNulls(){
        
        
        Test.startTest();
        
         //date
		SageUtility.parseDate(null);
        
        // decimal
		SageUtility.parseDecimal(null);
        
		// email
 		SageUtility.parseEmail(null);
        
        Test.stopTest();
        
    }
}