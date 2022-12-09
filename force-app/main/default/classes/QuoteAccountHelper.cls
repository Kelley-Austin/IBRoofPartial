public class QuoteAccountHelper {
    
    private List<Quote> oldList;
    private List<Quote> newList;
    
    public QuoteAccountHelper(List<Quote> oldList, List<Quote> newList) {
    	this.oldList = (oldList == null) ? new List<Quote>() : oldList;
    	this.newList = (newList == null) ? new List<Quote>() : newList;
    }
    
    public void execute() {
    	
    	List<Quote> quoteUpdateList = new List<Quote>();
    	
    	Set<Id> quoteIds = new Set<Id>();
    	
    	for (Quote qt : newList){
			quoteIds.add(qt.Id);
    	}
    	
    	for(Quote qt : [SELECT AccountId, Account__c FROM Quote WHERE Id IN :quoteIds]){
    		
    		if (qt.AccountId == qt.Account__c)
    			continue;
    			
    		qt.Account__c = qt.AccountId;
    		
    		quoteUpdateList.add(qt);
    	}
    	
    	try {
    		update quoteUpdateList;
    	} catch(Exception e){
    		system.debug(e);
    	}
    	
    }
}