global class AccountRegionBatch implements Database.Batchable<sObject>, Schedulable {
    public String query;

    public AccountRegionBatch() {
        this.query = 'SELECT Id, BillingPostalCode, ShippingPostalCode FROM Account WHERE SalespersonNo__c = null AND Account_Region__c = null AND (ShippingPostalCode != null OR BillingPostalCode != null)';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        AccountRegionHelper helper = new AccountRegionHelper();
        
        helper.addRegion(scope);
        
        try {
            update scope;
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext context) {
        Database.executeBatch(new AccountRegionBatch(), 200);
    }
}