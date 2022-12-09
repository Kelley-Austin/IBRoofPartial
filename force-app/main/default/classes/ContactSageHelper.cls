public class ContactSageHelper {
    private List<Contact> oldList;
    private List<Contact> newList;
    
    public ContactSageHelper(List<Contact> oldList, List<Contact> newList) {
    	this.oldList = (oldList == null) ? new List<Contact>() : oldList;
    	this.newList = (newList == null) ? new List<Contact>() : newList;
    }

    // AccountId,
    
	// MailingStreet,
	// MailingCity,
	// MailingState,
	// MailingPostalCode,
	// Salutation,
	// Title,
	// email,
	// Fax,
	// Phone)
    public void executeBeforeInsert() {
        for (Contact theContact : this.newList) {
            theContact.MailingCity = theContact.City__c;
            theContact.MailingState = theContact.State__c;
            theContact.MailingPostalCode = theContact.ZipCode__c;
            theContact.Title = theContact.ContactTitle__c;
            theContact.Fax = theContact.FaxNo__c;

            if (String.isBlank(theContact.ContactName__c) == false) {
                List<String> nameList = theContact.ContactName__c.split(' ');
                List<String> firstName = new List<String>();

                for (Integer i = 0; i < nameList.size() - 1; i++) {
                    firstName.add(nameList.get(i));
                }

                if (nameList.size() > 1) {
                    theContact.LastName = nameList.get(nameList.size() - 1);
                    theContact.FirstName = String.join(firstName, ' ');
                }
            }

            String mailingStreet = '';
            if (String.isBlank(theContact.AddressLine1__c) == false)
                mailingStreet += theContact.AddressLine1__c;

            if (String.isBlank(theContact.AddressLine2__c) == false)
                mailingStreet += theContact.AddressLine2__c;

            if (String.isBlank(theContact.AddressLine3__c) == false)
                mailingStreet += theContact.AddressLine3__c;

            if (String.isBlank(theContact.Salutation__c) == false && theContact.Salutation__c != 'None')
                theContact.Salutation = theContact.Salutation__c;

            if (String.isBlank(theContact.TelephoneNo1__c) == false) {
                String phone = theContact.TelephoneNo1__c;
                if (String.isBlank(theContact.TelephoneExt1__c) == false)
                    phone += ' ext ' + theContact.TelephoneExt1__c;
                
                theContact.Phone = phone;
            }
            
            if (theContact.EmailAddress__c != null && validateEmail(theContact.EmailAddress__c) == true) {
                theContact.Email = theContact.EmailAddress__c;
            }
        }
    }

    public void execute() {
        Set<String> accExternalIds = new Set<String>();

        for (Contact theContact : this.newList) {
            if (String.isBlank(theContact.LastName) == true)
                theContact.LastName = theContact.ContactName__c;

            if (String.isBlank(theContact.ARDivisionNo__c))
                continue;

            if (String.isBlank(theContact.CustomerNo__c))
                continue;

            accExternalIds.add(theContact.ARDivisionNo__c + '-' + theContact.CustomerNo__c);
        }

        List<Account> accList = [SELECT Id, External_Id__c FROM Account WHERE External_Id__c IN :accExternalIds];
        Map<String,Account> accByExternalIdMap = new Map<String,Account>();

        for (Account acc : accList) {
            accByExternalIdMap.put(acc.External_Id__c, acc);
        }

        for (Contact theContact : this.newList) {
            if (String.isBlank(theContact.ARDivisionNo__c))
                continue;

            if (String.isBlank(theContact.CustomerNo__c))
                continue;

            String externalId = theContact.ARDivisionNo__c + '-' + theContact.CustomerNo__c;
            Account acc = accByExternalIdMap.get(externalId);

            if (acc == null)
                continue;

            if (theContact.AccountId == acc.Id)
                continue;

            theContact.AccountId = acc.Id;
        }
    }

    public static Boolean validateEmail(String email) {
        Boolean res = true;
            
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
    }
}