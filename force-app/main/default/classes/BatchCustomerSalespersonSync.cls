global class BatchCustomerSalespersonSync 
            implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    // when SAGE100 Customer is updated, look for the respective account to see if the salesperson needs to be sync
    // if so, find the Salesperson record matching the Salesperson #
    // if it doesn't exist, create it
    // then assign the Salesperson record to the lookup field on the Account record
    
    // query to retrieve recently changed customers
    public static final String THEQUERY = 
            'SELECT Id, CommercientSF8__Account__c, CommercientSF8__ExternalKey__c '
            + ' , CommercientSF8__SALESPERSONNO__c, CommercientSF8__SalesPerson__c '
            + ' , CommercientSF8__SalesPerson__r.Name '
            + ' FROM CommercientSF8__AR_CUSTOMER__c '
            + ' WHERE CommercientSF8__SALESPERSONNO__c != null '
            + ' AND LastModifiedDate >= LAST_N_DAYS:';

    global static Integer batchSize = 2000;

    global Integer numberOfDays = 30;

    global BatchCustomerSalespersonSync() {
    }    
    global BatchCustomerSalespersonSync( Integer daysParameter ) {
        numberOfDays = daysParameter;
    }

    global Database.QueryLocator start( Database.BatchableContext context ) {
        numberOfDays = ( numberOfDays != null ? numberOfDays : 30 );
        String theQuery = THEQUERY + String.valueOf( numberOfDays );
        return Database.getQueryLocator( theQuery );
    }

    global void execute( Database.BatchableContext context, List<SObject> records ) {
        processRecords( records );
    }

    global void processRecords( List<CommercientSF8__AR_CUSTOMER__c> records ) {
        List<Error_Log__c> errorList = new List<Error_Log__c>();
        try {
            // collect external ids to retrieve accounts and salesperson numbers to compare
            Set<Id> accountIdSet = new Set<Id>();
            Set<String> userNameSet = new Set<String>();
            for( CommercientSF8__AR_CUSTOMER__c aCustomer : records ) {
                accountIdSet.add( aCustomer.CommercientSF8__Account__c );
                userNameSet.add( aCustomer.CommercientSF8__SalesPerson__r.Name );
            }
            accountIdSet.remove( null );

            if( accountIdSet.isEmpty() ) {
                return;
            }

            // retrieve accounts and create map to check salesperson number
            Map<Id, Account> accountMap = new Map<Id, Account> ( [
                SELECT Id, SalespersonNo__c 
                FROM Account 
                WHERE Id IN :accountIdSet
            ] );

            // retrieve users by name to associate with a salesperson record
            Map<String, User> userMap = getUsersByName( userNameSet );

            // check whether the salesperson still matches between Customer and Account (if not, it has been changed)
            // NOTE:  this can probably be replaced with a formula field to pull salesperson number from the related account
            Set<String> changedSalespersonNumberSet = getChangedSalespersonNumbers( records, accountMap );

            // retrieve salespersons to identify which ones already exist
            Map<String, Salesperson__c>  salespersonByNumberMap = getSalespersonsByNumber( changedSalespersonNumberSet );

            // collect accounts and salespersons to update/insert
            List<Account> accountsToUpdateList = new List<Account>();
            List<Salesperson__c> salespersonsToCreate = new List<Salesperson__c>();
            for( CommercientSF8__AR_CUSTOMER__c aCustomer : records ) {
                // skip if customer record's salesperson number hasn't changed
                if( ! changedSalespersonNumberSet.contains( aCustomer.CommercientSF8__SALESPERSONNO__c ) ) {
                    continue;
                }

                // find account that corresponds to the customer
                Account anAccount = accountMap.get( aCustomer.CommercientSF8__Account__c );
                if( anAccount == null ) {
                    continue;
                }

                // if salesperson doesn't exist, create the record and 
                // add to the collections and assign reference to account
                Salesperson__c aSalesperson = salespersonByNumberMap.get( aCustomer.CommercientSF8__SALESPERSONNO__c );
                if( aSalesperson == null ) {
                    aSalesperson = getNewSalesperson( aCustomer );

                    // find and assign user
                    User anUser = userMap.get( aSalesperson.SalespersonName__c );
                    aSalesperson.User__c = anUser?.Id;

                    // collect salesperson to be inserted
                    salespersonsToCreate.add( aSalesperson );
                    salespersonByNumberMap.put( aCustomer.CommercientSF8__SALESPERSONNO__c, aSalesperson );

                    // set the object reference in the account lookup (will be replaced with the id later)
                    anAccount.Sage_Salesperson_No__r = aSalesperson;

                } else {
                    // salesperson already exists, assign to account
                    anAccount.Sage_Salesperson_No__c = aSalesperson.Id;
                }

                // sync the rest of the account fields to the salesperson
                anAccount.SalespersonNo__c = aCustomer.CommercientSF8__SALESPERSONNO__c;
                if( aSalesperson.User__c != null ) {
                    anAccount.OwnerId = aSalesperson.User__c;
                }

                accountsToUpdateList.add( anAccount );
            }

            // insert salespersons and report errors, then convert object references to salesperson ids on accounts
            if( ! salespersonsToCreate.isEmpty() ) {
                Database.SaveResult[] insertResultList = Database.insert( salespersonsToCreate, FALSE );

                checkForErrors( errorList, insertResultList, salespersonsToCreate );

                // replace object references with respective ids on accounts
                for( Account anAccount : accountsToUpdateList ) {
                    if( anAccount.Sage_Salesperson_No__r == null ) {
                        continue;
                    }

                    anAccount.Sage_Salesperson_No__c = anAccount.Sage_Salesperson_No__r.Id;
                    anAccount.Sage_Salesperson_No__r = null;
                }
            }

            // update accounts and report errors
            if( ! accountsToUpdateList.isEmpty() ) {
                Database.SaveResult[] updateResultList = Database.update( accountsToUpdateList, FALSE );

                checkForErrors( errorList, updateResultList, accountsToUpdateList );
            }

        } catch( Exception e ) {
            String msg = e.getMessage() + ' / ' + e.getStackTraceString();
            system.debug( msg );
            addError( errorList, msg );

        } finally {
            if( ! errorList.isEmpty() ) {
                insert errorList;
            }
        }
    }

    public static Set<String> getChangedSalespersonNumbers( List<CommercientSF8__AR_CUSTOMER__c> records
                                                    , Map<Id, Account> accountMap ) {
        // return the salesperson numbers that have changed in the customer record compared to the respective account
        Set<String> changedSalespersonNumberSet = new Set<String>();
        for( CommercientSF8__AR_CUSTOMER__c aCustomer : records ) {
            // find account that corresponds to the customer
            Account anAccount = accountMap.get( aCustomer.CommercientSF8__Account__c );
            if( anAccount == null ) {
                continue;
            }

            // see if salesperson is still the same
            if( anAccount.SalespersonNo__c == aCustomer.CommercientSF8__SALESPERSONNO__c ) {
                continue;
            }

            // salesperson has been changed, so collect it to retrieve corresponding salesperson record
            changedSalespersonNumberSet.add( aCustomer.CommercientSF8__SALESPERSONNO__c );
        }

        return changedSalespersonNumberSet;
    }

    public static Map<String, User> getUsersByName( Set<String> userNameSet ) {
        List<User> userList = [
            SELECT Id, Name 
            FROM User 
            WHERE Name IN :userNameSet
        ];

        // create map of users indexed by name
        Map<String, User> userMap = new Map<String, User>();
        for( User anUser : userList ) {
            userMap.put( anUser.Name, anUser );
        }

        return userMap;
    }

    public static Map<String, Salesperson__c> getSalespersonsByNumber( Set<String> changedSalespersonNumberSet ) {
        List<Salesperson__c> salespersonList = [
            SELECT Id, Salesperson_No__c, User__c
            FROM Salesperson__c 
            WHERE Salesperson_No__c IN :changedSalespersonNumberSet
        ];

        // create map of salesperson indexed by number to identify the ones that need to be created
        Map<String, Salesperson__c> salespersonByNumberMap = new Map<String, Salesperson__c>();
        for( Salesperson__c aSalesperson : salespersonList ) {
            salespersonByNumberMap.put( aSalesperson.Salesperson_No__c, aSalesperson );
        }

        return salespersonByNumberMap;
    }

    public static Salesperson__c getNewSalesperson( CommercientSF8__AR_CUSTOMER__c aCustomer ) {
        String salespersonNumber = aCustomer.CommercientSF8__SALESPERSONNO__c;
        String salespersonName = aCustomer.CommercientSF8__SalesPerson__r.Name;
        // create salesperson
        Salesperson__c aSalesperson = new Salesperson__c();
        aSalesperson.SalespersonName__c = salespersonName;
        aSalesperson.Salesperson__c = salespersonName; // ext id
        aSalesperson.Name__c = salespersonName; // ext id

        aSalesperson.Name = salespersonNumber;
        aSalesperson.Salesperson_No__c = salespersonNumber; // ext id
        aSalesperson.External_Id__c = '00-' + salespersonNumber; // ext id

        return aSalesperson;
    }

    public static void addError( List<Error_Log__c> errorList, String msg ) {
        Error_Log__c anError = new Error_Log__c();
        anError.Message__c = msg;
        errorList.add( anError );
    }

    global void checkForErrors( List<Error_Log__c> errorList, List<Database.SaveResult> updateResultList
                                , List<SObject> recordsToUpdateList ) {
        for( Integer i = 0; i < updateResultList.size(); i++ ) {    
            Database.SaveResult aResult = updateResultList[ i ];
            if( aResult.isSuccess() ) {
                continue;
            }

            String msg = reportError( recordsToUpdateList[ i ], aResult );
            addError( errorList, msg );
        }
    }
    
    public static String reportError( SObject origRecord, Database.SaveResult aResult ) {
        Database.Error err = aResult.getErrors().get( 0 );
        System.debug( origRecord );
        String msg = 'RecordId : ' + origRecord.Id
                    + ' - Error : ' + err.getMessage() 
                    + '\n Status Code : ' + err.getStatusCode() 
                    + '\n Fields : ' + err.getFields() ;
        System.debug( msg );
        return msg;
    }

    global void finish( Database.BatchableContext BC ) {
        // if there were errors in the job execution, report them
        String errorMsg = getErrorsInBatch( BC?.getJobId() );
        if( errorMsg != '' ) {
            Error_Log__c anError = new Error_Log__c();
            anError.Message__c = errorMsg;
            insert anError;
        }
    } 

    public static String getErrorsInBatch( Id jobId ) {
        // retrieve child jobs
        List<AsyncApexJob> jobList = [
            SELECT Id, ParentJobId, ApexClassId, Status, ExtendedStatus
                    , NumberOfErrors, JobItemsProcessed, TotalJobItems 
            FROM AsyncApexJob 
            WHERE ParentJobId = :jobId
        ];
        if( jobList.isEmpty() ) {
            return null;
        }

        // collect child job's extended status to report as error
        String errorMsg = '';
        for( AsyncApexJob aJob : jobList ) {
            if( aJob.ExtendedStatus != null ) {
                errorMsg = errorMsg + '\n Job Id: ' + jobId + ' - ' + aJob.ExtendedStatus;
            }
        }

        return errorMsg;
    }
    
    // Method to execute Batch in Schedule time
    global static void scheduleMe( String strScheduleDateTime ) {
        // pickup changed customers in the last 30 days by default
        BatchCustomerSalespersonSync schClass = new BatchCustomerSalespersonSync( 30 );
        System.schedule( 'BatchCustomerSalespersonSync', strScheduleDateTime, schClass );
    }
    
    // Schedulable execute method - Accept the Chron Expression as a String to Schedule the time
    global void execute( SchedulableContext ctx ) {
        executeNow();
    }
    
    // Method to execute Batch immediately
    global static void executeNow() {
        BatchCustomerSalespersonSync batch = new BatchCustomerSalespersonSync();
        Id batchJobId = Database.executeBatch( batch, batchSize );
        System.debug( 'batchJobId: ' + batchJobId );
    }

}