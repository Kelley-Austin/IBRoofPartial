@RestResource(urlMapping='/sageContact/*')
global class SageContactEndpoint {
	
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        List<Contact> updateList = new List<Contact>();
        List<Contact> insertList = new List<Contact>();

        ContactRequest body;
        
        try {
            body = (ContactRequest) JSON.deserialize(req.requestBody.toString(), ContactRequest.class);
        } catch (Exception e) {
            System.debug(e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(e.getMessage());
            return;
        }

        Set<String> externalIds = new Set<String>();
        for (ContactRecord record : body.records) {
            externalIds.add(record.Sage_Contact_Code);
        }

        res.statusCode = 200;

        List<Database.SaveResult> results = new List<Database.SaveResult>();

        List<Contact> contactList = [SELECT Id, Sage_Contact_Code__c FROM Contact WHERE Sage_Contact_Code__c IN :externalIds];
        Map<String, Contact> contactByExternalId = new Map<String, Contact>();

        for (Contact theContact : contactList) {
            contactByExternalId.put(theContact.Sage_Contact_Code__c, theContact);
        }

        for (ContactRecord record : body.records) {
            if (contactByExternalId.containsKey(record.Sage_Contact_Code) == true) {
                Contact theContact = contactByExternalId.get(record.Sage_Contact_Code);
                mutateContactFields(theContact, record);

                updateList.add(theContact);
            } else {
                Contact theContact = new Contact();
                mutateContactFields(theContact, record);
                insertList.add(theContact);
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
        System.debug(resBody);


        // set primary contact fields on related account
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Account> accUpdateList = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        contacts.addAll(updateList);
        contacts.addAll(insertList);

        for (Contact theContact : contacts) {
            contactIds.add(theContact.Id);
        }
        contactIds.remove(null);
        
        List<Contact> contactAllList = [SELECT Id, AccountId, ARDivisionNo__c, CustomerNo__c, ContactCode__c, ContactName__c, Email FROM Contact WHERE Id IN :contactIds AND AccountId != null AND ARDivisionNo__c != null AND CustomerNo__c != null AND ContactCode__c != null];
        
        for (Contact theContact : contactAllList) {
            accountIds.add(theContact.AccountId);
        }

        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Account_Email__c, Primary_Contact__c, Primary_Contact_Email__c, ContactCode__c FROM Account WHERE Id IN :accountIds AND ContactCode__c != null]);

        for (Contact theContact : contactAllList) {
            Account acc = accountMap.get(theContact.AccountId);

            if (acc == null)
                continue;

            if (theContact.ContactCode__c != acc.ContactCode__c)
                continue;

            Boolean accNeedsUpdate = false;

            if (acc.Primary_Contact__c != theContact.ContactName__c) {
                acc.Primary_Contact__c = theContact.ContactName__c;
                accNeedsUpdate = true;
            }

            if (String.isBlank(theContact.Email)) {
                if (acc.Primary_Contact_Email__c != acc.Account_Email__c) {
                    acc.Primary_Contact_Email__c = acc.Account_Email__c;
                    accNeedsUpdate = true;
                }
            } else {
                if (acc.Primary_Contact_Email__c != theContact.Email) {
                    acc.Primary_Contact_Email__c = theContact.Email;
                    accNeedsUpdate = true;
                }
            }

            if (accNeedsUpdate)
                accUpdateList.add(acc);
        }

        try {
            update accUpdateList;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    private static void mutateContactFields(Contact theContact, ContactRecord record) {
        try{
            theContact.Sage_Contact_Code__c = record.Sage_Contact_Code;
            theContact.ARDivisionNo__c = record.ARDivisionNo;
            theContact.CustomerNo__c = record.CustomerNo;
            theContact.ContactCode__c = record.ContactCode;
            theContact.ContactName__c = record.ContactName;
            theContact.AddressLine1__c = record.AddressLine1;
            theContact.AddressLine2__c = record.AddressLine2;
            theContact.AddressLine3__c = record.AddressLine3;
            theContact.City__c = record.City;
            theContact.State__c = record.State;
            theContact.ZipCode__c = record.ZipCode;
            theContact.CountryCode__c = record.CountryCode;
            theContact.Salutation__c = record.Salutation;
            theContact.ContactTitle__c = record.ContactTitle;
            theContact.TelephoneNo1__c = record.TelephoneNo1;
            theContact.TelephoneExt1__c = record.TelephoneExt1;
            theContact.TelephoneNo2__c = record.TelephoneNo2;
            theContact.TelephoneExt2__c = record.TelephoneExt2;
            theContact.FaxNo__c = record.FaxNo;
            theContact.EmailAddress__c = record.EmailAddress;
        }catch (Exception e){
            system.debug(e.getMessage());
        }
        
    }

    public class ContactRequest {
        public Boolean allOrNone;
        public List<ContactRecord> records;
    }

    public class ContactRecord {
        public ContactAttributes attributes;
        public String Sage_Contact_Code;
        public String ARDivisionNo;
        public String CustomerNo;
        public String ContactCode;
        public String ContactName;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String City;
        public String State;
        public String ZipCode;
        public String CountryCode;
        public String Salutation;
        public String ContactTitle;
        public String TelephoneNo1;
        public String TelephoneExt1;
        public String TelephoneNo2;
        public String TelephoneExt2;
        public String FaxNo;
        public String EmailAddress;
    }

    public class ContactAttributes {
        public String type;
    }

    public class ResponseItem {
        public String id;
        public Boolean success;
        public List<Database.Error> errors;
        public Contact theContact;

        public ResponseItem(String id, Boolean success, List<Database.Error> errors, Contact theContact) {
            this.id = id;
            this.success = success;
            this.errors = errors;
            this.theContact = theContact;
        }
    }
}