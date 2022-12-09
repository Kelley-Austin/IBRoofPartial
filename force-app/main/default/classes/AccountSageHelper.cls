public class AccountSageHelper {
    private List<Account> oldList;
    private List<Account> newList;
    
    public AccountSageHelper(List<Account> oldList, List<Account> newList) {
    	this.oldList = (oldList == null) ? new List<Account>() : oldList;
    	this.newList = (newList == null) ? new List<Account>() : newList;
    }

    public void executeBeforeInsert() {
        for (Account acc : this.newList) {
            acc.Customer_Number__c = acc.CustomerNo__c;
            acc.Account_Status__c = acc.UDF_ACCOUNT_STATUS__c;
            acc.Credit_Hold__c = acc.CreditHold__c;
            acc.Territory__c = acc.UDF_TERRITORY__c;
            acc.ShippingStreet = acc.AddressLine1__c;
            acc.ShippingCity = acc.City__c;
            acc.ShippingPostalCode = acc.ZipCode__c;
            acc.Phone = acc.TelephoneNo__c;
            acc.Fax = acc.FaxNo__c;
            acc.Website = acc.URLAddress__c;
            
            if (acc.UDF_IB_COOPSQ__c != null)
                acc.Total_Squares_Purchased__c = decimal.valueOf(acc.UDF_IB_COOPSQ__c);

            if (acc.UDF_IB_COOPPOINTSAVAILABLE__c != null)
                acc.IB_Reward_Dollars__c = decimal.valueOf(acc.UDF_IB_COOPPOINTSAVAILABLE__c);

            if (acc.CreditLimit__c != null)
                acc.Credit_Limit__c = decimal.valueOf(acc.CreditLimit__c);

            if (acc.EmailAddress__c != null && validateEmail(acc.EmailAddress__c) == true) {
                acc.Account_Email__c = acc.EmailAddress__c;
                acc.Warrantied_Account_Email__c = acc.EmailAddress__c;
            }
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