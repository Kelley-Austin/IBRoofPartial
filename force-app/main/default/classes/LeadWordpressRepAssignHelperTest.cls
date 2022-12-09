@isTest
private class LeadWordpressRepAssignHelperTest {

    static testMethod void myUnitTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'pagate', Email='testagate@ibroof.com', 
            EmailEncodingKey='UTF-8', LastName='pagate', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testagate@ibroof.com');
        
        insert u;

        Lead testLead = new Lead(
            LeadSource = 'Website',
            FirstName = 'test',
            LastName = 'test',
            email = 'test@email.com',
            company = 'test company',
            PostalCode = '00000',
            phone = '1234567890',
            IB_Roof_Website_Rep_Email__c = 'testagate@ibroof.com',
            description = 'test message',
            Contractor__c = 'Contractor',
            Filter__c = 'Find A Rep',
            Full_Address__c = 'test address'
        );

        insert testLead;

        List<Lead> leadList = [SELECT Id, OwnerId FROM Lead WHERE Id = :testLead.Id];

        update testLead;

        System.assertEquals(u.Id, leadList.get(0).OwnerId);
    }
}