global class TaxRatesBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    public String query;
    public Date sixMonthsAgo;

    public TaxRatesBatch() {
        this.query = 'SELECT Id, Tax_Rate_Updated_At__c, Zip__c, Tax_Rate__c FROM Project__c WHERE Zip__c != null AND (Tax_Rate_Updated_At__c = null OR Tax_Rate_Updated_At__c <= ' + String.valueOf(System.today().addMonths(-6)) + ')';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (scope == null)
            return;

        Map<String,String> taxResponseByZipCode = new Map<String,String>();

        List<Project__c> updateList = new List<Project__c>();

        for(Project__c project : (List<Project__c>) scope) {
            String zip = project.Zip__c;

            if (zip != null) {

                if (taxResponseByZipCode.containsKey(zip) == true) {
                    if (project.Tax_Rate__c != taxResponseByZipCode.get(zip)) {
                        project.Tax_Rate__c = taxResponseByZipCode.get(zip);
                        project.Tax_Rate_Updated_At__c = System.today();
                        updateList.add(project);
                    }
                    continue;
                }

                AvalaraTaxRatesAPIService.TaxResponse taxResponse;
                try {
                    taxResponse = AvalaraTaxRatesAPIService.getTaxRates(zip, 'US');
                } catch (Exception e) {
                    system.debug(e.getMessage());
                    continue; // should we continue or return if it errors out?
                }

                String taxResponseSerialized = JSON.serialize(taxResponse);
                taxResponseByZipCode.put(zip, taxResponseSerialized);

                if (project.Tax_Rate__c != taxResponseSerialized) {
                    project.Tax_Rate__c = taxResponseSerialized;
                    project.Tax_Rate_Updated_At__c = System.today();
                    updateList.add(project);
                }
            }
        }

        try {
            update updateList;
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext context) {
        Database.executeBatch(new TaxRatesBatch(), 10);
    }
}