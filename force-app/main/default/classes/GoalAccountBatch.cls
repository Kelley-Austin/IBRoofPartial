global class GoalAccountBatch implements Database.Batchable<sObject> {

    private String query;

    public GoalAccountBatch() {

        this.query = 'SELECT Id,'+
                        ' Salesperson_Id__c,'+
                        ' External_Id__c'+
                    ' FROM Goal__c'+
                    ' WHERE Salesperson_Id__c != null'+
                    ' AND External_Id__c != null';

    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }
   
    public void execute(Database.BatchableContext BC, List<sObject> scope){

        

        Set<String> salespersonIds = new Set<String>();
        
        for (Goal__c goal : (List<Goal__c>) scope){
            salespersonIds.add(goal.Salesperson_Id__c);
        }

        List<Account> accountList = [SELECT Id,
                                            SalespersonDivisionNo__c,
                                            SalespersonNo__c,
                                            Sage_Created_Date__c,
                                            Udf_Account_Status__c,
                                     		UDF_Account_Status2__c,
                                     		Date_Established__c,
                                            (SELECT Id, FiscalPeriod__c, FiscalYear__c
                                             FROM Customer_Sales_History__r 
                                             WHERE Dollars_Sold__c > 0
                                             AND FiscalYear__c = :DateTime.now().format('yyyy'))
                                    FROM Account
                                    WHERE SalespersonNo__c IN :salespersonIds];

        for (Goal__c goal : (List<Goal__c>) scope){
            Integer activeCustomers = 0;
            Integer buyingCustomersMonth = 0;
            Integer customersAddedCy = 0;

            for (Account acct : accountList){

                String key = acct.SalespersonDivisionNo__c +'-'+ acct.SalespersonNo__c;

                if (key != goal.External_Id__c)
                    continue;

                if (acct.UDF_Account_Status2__c == 'A'){//Old acct.Udf_Account_Status__c == 'Active Customer'
                    activeCustomers++;
                }

                for (Customer_Sales_History__c csh : acct.Customer_Sales_History__r){

                    //system.debug('csh.FiscalYear__c -> '+ csh.FiscalYear__c);
                    //system.debug('DateTime.now().format(\'yyyy\') ->'+ DateTime.now().format('yyyy'));
                    //system.debug(csh.FiscalYear__c == DateTime.now().format('yyyy'));

                    if (csh.FiscalYear__c == DateTime.now().format('yyyy') && csh.FiscalPeriod__c == DateTime.now().format('MM')){
                        buyingCustomersMonth++;
                        break;
                    }
                }

                if (acct.Date_Established__c != null && acct.Date_Established__c.year() == Date.today().year()){//Old acct.Sage_Created_Date__c != null && acct.Sage_Created_Date__c.year() == Date.today().year()
                    customersAddedCy++;
                }
            }

            goal.Active_Customers_Current_Month__c = activeCustomers;
            goal.Buying_Customers_Current_Month__c = buyingCustomersMonth;
            goal.New_Customers_Current_Year__c = customersAddedCy;
        }


        try {
            update scope;
        } catch (Exception e) {
            system.debug(e.getMessage());
        }

        
    }

    public void finish(Database.BatchableContext BC){}

}