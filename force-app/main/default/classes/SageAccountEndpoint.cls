@RestResource(urlMapping='/sageAccount/*')
global class SageAccountEndpoint {
	
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        List<Account> updateList = new List<Account>();
        List<Account> insertList = new List<Account>();

        AccountRequest body;
        
        try {
            body = (AccountRequest) JSON.deserialize(req.requestBody.toString(), AccountRequest.class);
        } catch (Exception e) {
            System.debug(e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(e.getMessage());
            return;
        }

        Set<String> externalIds = new Set<String>();
        for (AccountRecord record : body.records) {
            externalIds.add(record.external_id);
        }

        List<User> userList = [SELECT Id, MAS_ID__c FROM User WHERE MAS_ID__c != null AND isActive = true];
        Map<String,User> userByTechRepId = new Map<String,User>();

        for (User user : userList) {
            userByTechRepId.put(user.MAS_ID__c, user);
        }

        res.statusCode = 200;

        List<Database.SaveResult> results = new List<Database.SaveResult>();

        List<Account> accList = [SELECT Id, Warrantied_Account_Email__c, External_Id__c FROM Account WHERE External_Id__c IN :externalIds];
        Map<String, Account> accByExternalId = new Map<String, Account>();

        for (Account acc : accList) {
            accByExternalId.put(acc.External_Id__c, acc);
        }

        for (AccountRecord record : body.records) {
            if (accByExternalId.containsKey(record.external_id) == true) {
                Account acc = accByExternalId.get(record.external_id);
                mutateAccFields(acc, record, userByTechRepId);

                updateList.add(acc);
            } else {
                Account acc = new Account();
                mutateAccFields(acc, record, userByTechRepId);
                insertList.add(acc);
            }
        }

        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        dml.OptAllOrNone = false;

        List<ResponseItem> resBody = new List<ResponseItem>();

        List<Database.SaveResult> updateResult = Database.update(updateList, dml);

        for (Integer i = 0; i < updateResult.size(); i++) {
            resBody.add(new ResponseItem(updateResult.get(i).getId(), updateResult.get(i).isSuccess(), updateResult.get(i).getErrors(), updateList.get(i)));
        }

        List<Database.SaveResult> insertResult = Database.insert(insertList, dml);

        for (Integer i = 0; i < insertResult.size(); i++) {
            resBody.add(new ResponseItem(insertResult.get(i).getId(), insertResult.get(i).isSuccess(), insertResult.get(i).getErrors(), insertList.get(i)));
        }

        res.responseBody = Blob.valueOf(JSON.serialize(resBody));

        System.debug(res);
    }

    @TestVisible
    private static String getStreetAddress(AccountRecord record) {
        String streetAddress = '';

        if (String.isBlank(record.AddressLine1) == false && record.AddressLine1 != 'None') {
            streetAddress += record.AddressLine1;
        }

        if (String.isBlank(record.AddressLine2) == false && record.AddressLine2 != 'None') {
            streetAddress += '\n' + record.AddressLine2;
        }

        if (String.isBlank(record.AddressLine3) == false && record.AddressLine3 != 'None') {
            streetAddress += '\n' + record.AddressLine3;
        }

        return streetAddress;
    }
	
    @TestVisible
    private static void mutateAccFields(Account acc, AccountRecord record, Map<String, User> userByTechRepId) {

        acc.Customer_Number__c = record.CustomerNo;

        if (userByTechRepId.containsKey(record.UDF_TECHREP)) {
            acc.Assigned_Tech_Rep__c = userByTechRepId.get(record.UDF_TECHREP).Id;
        }

        if (userByTechRepId.containsKey(record.UDF_SUBREP)) {
            acc.Assigned_ISR__c = userByTechRepId.get(record.UDF_SUBREP).Id;
        }
        
        acc.ShippingStreet = getStreetAddress(record);
        acc.ShippingCity = record.City;
        acc.ShippingPostalCode = record.ZipCode;
        acc.ShippingState = record.State;
        
        acc.Phone = record.TelephoneNo;
        acc.Fax = record.FaxNo;
        acc.Website = record.URLAddress;
        
       
        acc.Account_Status__c = record.UDF_ACCOUNT_STATUS;
        acc.Credit_Hold__c = record.CreditHold;
        acc.Territory__c = record.UDF_TERRITORY;

        
        //email
        acc.Account_Email__c = SageUtility.parseEmail(record.EmailAddress);
        
        acc.External_Id__c = record.external_id;
        acc.SalespersonDivisionNo__c = record.SalespersonDivisionNo;
        acc.SalespersonNo__c = record.SalespersonNo;
        acc.Name = record.CustomerName;
        acc.ARDivisionNo__c = record.ARDivisionNo;
        acc.CustomerNo__c = record.CustomerNo;
        acc.CustomerName__c = record.CustomerName;
        acc.AddressLine1__c = record.AddressLine1;
        acc.AddressLine2__c = record.AddressLine2;
        acc.AddressLine3__c = record.AddressLine3;
        acc.City__c = record.City;
        acc.State__c = record.State;
        acc.ZipCode__c = record.ZipCode;
        acc.CountryCode__c = record.CountryCode;
        acc.TelephoneNo__c = record.TelephoneNo;
        acc.TelephoneExt__c = record.TelephoneExt;
        acc.FaxNo__c = record.FaxNo;
        acc.EmailAddress__c = record.EmailAddress;
        acc.URLAddress__c = record.URLAddress;
        acc.CustomerType__c = record.CustomerType;
        acc.PriceLevel__c = record.PriceLevel;
        acc.DateLastActivity__c = record.DateLastActivity;
        acc.DateLastPayment__c = record.DateLastPayment;
        acc.DateLastStatement__c = record.DateLastStatement;
        acc.DateLastFinanceChrg__c = record.DateLastFinanceChrg;
        acc.DateLastAging__c = record.DateLastAging;
        acc.CreditHold__c = record.CreditHold;
        acc.TermsCode__c = record.TermsCode;
        acc.UDF_REGION__c = record.UDF_REGION;
        acc.UDF_TECHREP__c = record.UDF_TECHREP;
        acc.UDF_SUBREP__c = record.UDF_SUBREP;
        acc.UDF_GEARPOINTSAVAILABLE__c = record.UDF_GEARPOINTSAVAILABLE;
        acc.UDF_ACCOUNT_STATUS__c = record.UDF_ACCOUNT_STATUS;
        acc.UDF_EMAILS__c = record.UDF_EMAILS;
        acc.UDF_TERRITORY__c = record.UDF_TERRITORY;
        acc.UDF_IB_COOPPOINTSAVAILABLE__c = record.UDF_IB_COOPPOINTSAVAILABLE;
        acc.UDF_IB_COOPSQ__c = record.UDF_IB_COOPSQ;
        acc.ContactCode__c = record.ContactCode;
        
        //date
        acc.Sage_Created_Date__c = SageUtility.parseDate(record.DateCreated);
        
        //decimal
        acc.Total_Squares_Purchased__c = SageUtility.parseDecimal(record.UDF_IB_COOPSQ);
        acc.IB_Reward_Dollars__c = SageUtility.parseDecimal(record.UDF_IB_COOPPOINTSAVAILABLE);
        acc.Credit_Limit__c = SageUtility.parseDecimal(record.CreditLimit);
        
        // email
        acc.Warrantied_Account_Email__c = (acc.Warrantied_Account_Email__c != null)? acc.Warrantied_Account_Email__c : SageUtility.parseEmail(record.EmailAddress);
        
    }
    
    public class AccountRequest {
        public Boolean allOrNone;
        public List<AccountRecord> records;
    }

    public class AccountRecord {
        public AccountAttributes attributes;
        public String External_Id;
        public String SalespersonDivisionNo;
        public String SalespersonNo;
        public String ARDivisionNo;
        public String CustomerNo;
        public String CustomerName;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String City;
        public String State;
        public String ZipCode;
        public String CountryCode;
        public String TelephoneNo;
        public String TelephoneExt;
        public String FaxNo;
        public String EmailAddress;
        public String URLAddress;
        public String CustomerType;
        public String PriceLevel;
        public String DateLastActivity;
        public String DateLastPayment;
        public String DateLastStatement;
        public String DateLastFinanceChrg;
        public String DateLastAging;
        public String CreditHold;
        public String TermsCode;
        public String UDF_REGION;
        public String UDF_TECHREP;
        public String UDF_GEARPOINTSAVAILABLE;
        public String UDF_ACCOUNT_STATUS;
        public String UDF_EMAILS;
        public String UDF_TERRITORY;
        public String UDF_IB_COOPPOINTSAVAILABLE;
        public String UDF_IB_COOPSQ;
        public String DateCreated;
        public String ContactCode;
        public String CreditLimit;
        public String UDF_SUBREP;
    }

    public class AccountAttributes {
        public String type;
    }

    public class ResponseItem {
        public String id;
        public Boolean success;
        public List<Database.Error> errors;
        public Account acc;

        public ResponseItem(String id, Boolean success, List<Database.Error> errors, Account acc) {
            this.id = id;
            this.success = success;
            this.errors = errors;
            this.acc = acc;
        }
    }
}