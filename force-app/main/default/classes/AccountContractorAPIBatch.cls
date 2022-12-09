global class AccountContractorAPIBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    public String query;

    public AccountContractorAPIBatch() {
        this.query = 'SELECT Id FROM Account WHERE Customer_Number__c != null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        for (Account acc : (List<Account>) scope) {
            AccountContractorAPICall.sendCSATDataNotFuture(acc.Id);
        }
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext context) {
        Database.executeBatch(new AccountContractorAPIBatch(), 10);
    }
}