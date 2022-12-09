public class SageUtility {
    
	public static String parseEmail(String sageEmailStr){
        if (validateEmail(sageEmailStr) == false)
            return null;
        
        return sageEmailStr;
    }
    
 	public static Decimal parseDecimal(String sageDecimalStr){
        
        if (sageDecimalStr == null)
            return null;
        
        Decimal sageDecimal;
        
        try{
            sageDecimal = Decimal.valueOf(sageDecimalStr);
        }catch (Exception e){
            system.debug(e.getMessage());
        }
       	return sageDecimal; 
    }
    
	public static Date parseDate(String sageDateStr){
        
        if (sageDateStr == null)
            return null;
        
        Date sageDate;
        
        try{
            sageDate = Date.valueOf(sageDateStr);
        }catch (Exception e){
            system.debug(e.getMessage());
        }
       	return sageDate;
    }
    
    public static Boolean validateEmail(String email) {
        if (email == null)
            return false;
        
        Boolean res = true;
            
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
    }

}