@isTest
public class BatchCustomerSalespersonSyncTest {

    @TestSetup
    public static void createData() {
        // CommercientSF8__AR_CUSTOMER__c -> CommercientSF8__SAGE100_SalesPerson__c and Account
        // Salesperson__c -> User

        Integer nbrRecords = 10;

        // Create a list of 10 records of each object
        List<CommercientSF8__SAGE100_SalesPerson__c> sage100Salespersons = new List<CommercientSF8__SAGE100_SalesPerson__c>();
        List<Account> accounts = new List<Account>();
        for( Integer i = 0; i < nbrRecords; i++ ) {
            CommercientSF8__SAGE100_SalesPerson__c sage100Salesperson = new CommercientSF8__SAGE100_SalesPerson__c();
            sage100Salesperson.Name = 'Joe Name ' + i;
            sage100Salespersons.add( sage100Salesperson );

            Account account = new Account();
            account.Name = 'Test Account ' + i;
            account.SalespersonNo__c = String.valueOf( i );
            accounts.add( account );
        }
        insert sage100Salespersons;
        insert accounts;

        List<CommercientSF8__AR_CUSTOMER__c> customers = new List<CommercientSF8__AR_CUSTOMER__c>();
        for( Integer i = 0; i < nbrRecords; i++ ) {
            CommercientSF8__AR_CUSTOMER__c customer = getNewSage100Customer( i );
            customer.CommercientSF8__Account__c = accounts[ i ].Id;
            customer.CommercientSF8__SalesPerson__c = sage100Salespersons[ i ].Id;
            customers.add( customer );
        }
        insert customers;

        Id stdProfileId = getStandardProfileId();

        // Create a list of Users
        List<User> users = new List<User>();
        for( Integer i = 0; i < nbrRecords; i++ ) {
            User anUser = getNewUser( i, stdProfileId );
            users.add( anUser );
        }
        insert users;

        // Create a list of Salesperson__c records
        List<Salesperson__c> salespersons = new List<Salesperson__c>();
        for( Integer i = 0; i < nbrRecords; i++ ) {
            User anUser = users[ i ];
            Salesperson__c salesperson = new Salesperson__c();
            salesperson.Name = String.valueOf( i );
            salesperson.Salesperson_No__c = salesperson.Name;
            salesperson.SalespersonName__c = anUser.FirstName + ' ' + anUser.LastName;
            salesperson.User__c = anUser.Id;
            salespersons.add( salesperson );
        }
        insert salespersons;
    }

    public static CommercientSF8__AR_CUSTOMER__c getNewSage100Customer( Integer i ) {
        CommercientSF8__AR_CUSTOMER__c customer = new CommercientSF8__AR_CUSTOMER__c();
        customer.Name = 'Test Customer ' + i;
        customer.CommercientSF8__SALESPERSONNO__c = String.valueOf( i );
        customer.CommercientSF8__ExternalKey__c = '00:' + i;

        return customer;
    }

    public static Id getStandardProfileId() {
        Profile stdProfile = [ 
            SELECT Id 
            FROM Profile 
            WHERE Name = 'Standard User'
        ];
        return stdProfile.Id;
    }

    public static User getNewUser( Integer i, Id profileId ) {
        User anUser = new User();
        anUser.FirstName = 'Joe';
        anUser.LastName = 'Name ' + i;
        anUser.Email = 'test' + i + '@test.com';
        anUser.Username = anUser.Email + '.batchcustomer';
        anUser.Alias = 'abatch' + i;
        anUser.CommunityNickname = anUser.LastName;
        anUser.ProfileId = profileId;
        anUser.TimeZoneSidKey = 'America/New_York';
        anUser.LocaleSidKey = 'en_US';
        anUser.EmailEncodingKey = 'UTF-8';
        anUser.LanguageLocaleKey = 'en_US';
        return anUser;
    }

    @isTest
    public static void testBatchExecution() {
        Test.startTest();

        List<CommercientSF8__AR_CUSTOMER__c> customerList = [
            SELECT Id, CommercientSF8__Account__c, CommercientSF8__ExternalKey__c
                    , CommercientSF8__SALESPERSONNO__c, CommercientSF8__SalesPerson__c
                    , CommercientSF8__SalesPerson__r.Name, LastModifiedDate 
            FROM CommercientSF8__AR_CUSTOMER__c 
            WHERE CommercientSF8__SALESPERSONNO__c != null 
        ];

        BatchCustomerSalespersonSync.scheduleMe( '0 0 0 1 1 ? *' );

        BatchCustomerSalespersonSync.executeNow();

        BatchCustomerSalespersonSync batchLoad = new BatchCustomerSalespersonSync( null );
        batchLoad.processRecords( customerList );

        test.stopTest();
    }

    @isTest
    public static void testChangedSalespersonToAnother() {
        Test.startTest();

        List<CommercientSF8__AR_CUSTOMER__c> customerList = [
            SELECT Id, CommercientSF8__Account__c, CommercientSF8__ExternalKey__c
                    , CommercientSF8__SALESPERSONNO__c, CommercientSF8__SalesPerson__c
                    , CommercientSF8__SalesPerson__r.Name, LastModifiedDate 
            FROM CommercientSF8__AR_CUSTOMER__c 
            WHERE CommercientSF8__SALESPERSONNO__c != null 
        ];

        // change salesperson on a customer to cause a sync on Account
        CommercientSF8__AR_CUSTOMER__c aCustomer = customerList[ 0 ];
        aCustomer.CommercientSF8__SALESPERSONNO__c = '1';
        update aCustomer;

        BatchCustomerSalespersonSync batchLoad = new BatchCustomerSalespersonSync( null );
        batchLoad.processRecords( customerList );

        Account anAccount = [
            SELECT Id, Name, SalespersonNo__c
                , Sage_Salesperson_No__r.Name, Sage_Salesperson_No__r.SalespersonName__c
            FROM Account 
            WHERE Name = 'Test Account 0' 
        ];

        test.stopTest();

        Assert.areEqual( '1', anAccount.Sage_Salesperson_No__r.Name, 'account salesperson changed properly' );
        Assert.areEqual( 'Joe Name 1', anAccount.Sage_Salesperson_No__r.SalespersonName__c, 'salesperson changed ok' );
    }

    @isTest
    public static void testChangedSalespersonToNewOne() {
        Test.startTest();

        Id stdProfileId = getStandardProfileId();
        User anUser = getNewUser( 11, stdProfileId );
        insert anUser;

        // new SAGE 100 salesperson
        CommercientSF8__SAGE100_SalesPerson__c sage100Salesperson = new CommercientSF8__SAGE100_SalesPerson__c();
        sage100Salesperson.Name = 'Joe Name 11';
        insert sage100Salesperson;

        // change salesperson on a customer to cause a sync on Account
        CommercientSF8__AR_CUSTOMER__c aCustomer = [
            SELECT Id, CommercientSF8__Account__c, CommercientSF8__ExternalKey__c
                    , CommercientSF8__SALESPERSONNO__c, CommercientSF8__SalesPerson__c
                    , CommercientSF8__SalesPerson__r.Name, LastModifiedDate 
            FROM CommercientSF8__AR_CUSTOMER__c 
            WHERE CommercientSF8__Account__r.Name = 'Test Account 0'
        ];

        // Salesperson Number	CommercientSF8__SALESPERSONNO__c - text
        aCustomer.CommercientSF8__SALESPERSONNO__c = '11';
        // SalesPerson	CommercientSF8__SalesPerson__c - lookup to SAGE100 SalesPerson
        aCustomer.CommercientSF8__SalesPerson__c = sage100Salesperson.Id;
        update aCustomer;

        List<CommercientSF8__AR_CUSTOMER__c> customerList = [
            SELECT Id, CommercientSF8__Account__c, CommercientSF8__ExternalKey__c
                    , CommercientSF8__SALESPERSONNO__c, CommercientSF8__SalesPerson__c
                    , CommercientSF8__SalesPerson__r.Name, LastModifiedDate 
            FROM CommercientSF8__AR_CUSTOMER__c 
            WHERE CommercientSF8__SALESPERSONNO__c != null 
        ];

        BatchCustomerSalespersonSync batchLoad = new BatchCustomerSalespersonSync( null );
        batchLoad.processRecords( customerList );

        Account anAccount = [
            SELECT Id, Name, SalespersonNo__c
                , Sage_Salesperson_No__r.Name, Sage_Salesperson_No__r.SalespersonName__c
            FROM Account 
            WHERE Name = 'Test Account 0' 
        ];

        test.stopTest();

        Assert.areEqual( '11', anAccount.Sage_Salesperson_No__r.Name, 'account salesperson changed properly' );
        Assert.areEqual( 'Joe Name 11', anAccount.Sage_Salesperson_No__r.SalespersonName__c, 'salesperson changed ok' );
    }

    @isTest
    public static void increaseCoverage() {
        test.startTest();

        List<Error_Log__c> errorList = new List<Error_Log__c>();
        BatchCustomerSalespersonSync.addError( errorList, 'error message' );
        Assert.areEqual( 1, errorList.size() );

        Account anAccount = new Account();
        Database.SaveResult aResult = Database.insert( anAccount, false );

        String msg = BatchCustomerSalespersonSync.reportError( anAccount, aResult );
        Assert.areEqual( true, msg.containsIgnoreCase( 'Required fields are missing: [Name]' ) );

        test.stopTest();


    }
}

