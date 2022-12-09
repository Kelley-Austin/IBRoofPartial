public class AccountContractorAPICall {
    @future(callout=true)
    public static void sendCSATData(Id idscurrentcontext){
        
        string request_string = getCSATData(idscurrentcontext);
        system.debug('Request Json String:::::: '+ request_string);
        Http http1=new Http();
        HttpRequest req1=new HttpRequest();
        req1.setendpoint('https://www.ibroof.com/contractor_api.php');
        req1.setmethod('POST'); 
        req1.setTimeout(120000);
        req1.setbody(request_string);
        HttpResponse res1;
        res1 = http1.send(req1);
        String response_string =res1.getbody();
        system.debug('sendCSATData Response Json String::: ' + response_string);
    }
    public static string getCSATData(Id idscurrentcontext){
        string returnjson;
        list<account> acc = [select Id,Name,BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone,Warrantied_Account_Email__c,Customer_Number__c  from account where Id =: idscurrentcontext and Customer_Number__c != null];
        if(acc.size()>0){
            string wemail = acc[0].Warrantied_Account_Email__c !=null?acc[0].Warrantied_Account_Email__c.replace('&','####'):acc[0].Warrantied_Account_Email__c;
            string waddress = acc[0].BillingStreet != null?acc[0].BillingStreet.replace('&','####'):acc[0].BillingStreet;
            returnjson = 'data'+'='+'{'+'"wwcn_fullname"'+':'+'"'+acc[0].Name.replace('&','####')+'"'+','+'"wwcn_email"'+':'+'"'+wemail+'"'+','+'"wwcn_phone"'+':'+'"'+acc[0].Phone+'"'+','+'"wwcn_city"'+':'+'"'+acc[0].BillingCity+'"'+','+'"wwcn_state"'+':'+'"'+acc[0].BillingState+'"'+','+'"wwcn_zipcode"'+':'+'"'+acc[0].BillingPostalCode+'"'+','+'"wwcn_certificate_number"'+':'+'"'+acc[0].Customer_Number__c+'"'+','+'"wwcn_address"'+':'+'"'+waddress+'"'+'}';
        }else{
            returnjson = 'no record found';
        }
        return returnjson;
    }
    @future(callout=true)
    public static void deleteCSATData(string delRec){
        string returnjson1 = 'data'+'='+'{'+'"wwcn_certificate_number"'+':'+'"'+delRec+'"'+'}';
        //string request_string1 = getCSATData1(delRec);
        // system.debug('Request Json String delete :::::: '+ request_string1);
        Http http1=new Http();
        HttpRequest req1=new HttpRequest();
        req1.setendpoint('https://www.ibroof.com/contractor_delete_api.php');
        req1.setmethod('POST'); 
        req1.setTimeout(120000);
        req1.setbody(returnjson1);
        HttpResponse res1;
        res1 = http1.send(req1);
        String response_string =res1.getbody();
        system.debug('sendCSATData Response Json String::: ' + response_string);
    }

    public static void sendCSATDataNotFuture(Id idscurrentcontext){
        string request_string = getCSATData(idscurrentcontext);
        system.debug('Request Json String:::::: '+ request_string);
        Http http1=new Http();
        HttpRequest req1=new HttpRequest();
        req1.setendpoint('https://www.ibroof.com/contractor_api.php');
        req1.setmethod('POST'); 
        req1.setTimeout(120000);
        req1.setbody(request_string);
        HttpResponse res1;
        res1 = http1.send(req1);
        String response_string =res1.getbody();
        system.debug('sendCSATData Response Json String::: ' + response_string);
    }
    /* public static string getCSATData1(Id idscurrentcontext){
system.debug('============> '+idscurrentcontext);
list<account> acc1 = [select Id,Name,Customer_Number__c  from account where Id =: idscurrentcontext];
string returnjson1 = 'data'+'='+'{'+'"certificate_number"'+':'+'"'+acc1[0].Customer_Number__c+'"'+'}';
return returnjson1;
}*/   
}