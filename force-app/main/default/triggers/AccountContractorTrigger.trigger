trigger AccountContractorTrigger on Account (after insert,after update,before delete) {
    
    if(Trigger.isInsert || Trigger.isUpdate){
        list<account> acc = trigger.new;
        if(!test.isRunningTest() && System.isFuture() == false && System.isBatch() == false){
            AccountContractorAPICall.sendCSATData(acc[0].Id);
        }
    }
    if(Trigger.isDelete){
        Id rId;
        string certificateNumber;
        for(account f: Trigger.old) {
            rId = f.Id;
            certificateNumber = f.Customer_Number__c;
        }
        list<account> acc1 = trigger.old;
        
        if (!test.isRunningTest() && System.isFuture() == false && System.isBatch() == false){
            AccountContractorAPICall.deleteCSATData(certificateNumber);
        }
    }
    
}