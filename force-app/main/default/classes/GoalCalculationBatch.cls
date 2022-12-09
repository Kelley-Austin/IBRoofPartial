global class GoalCalculationBatch implements Database.Batchable<sObject>, Database.stateful {

    private String query;

    private Map<String,Goal__c> goalMap; 

    public GoalCalculationBatch() {

        this.query = 'SELECT Id,'+
                        ' Dollars_Sold__c,'+
                        ' FiscalYear__c,'+
                        ' FiscalPeriod__c,'+
                        ' Customer__c,'+
                        ' Customer__r.SalespersonDivisionNo__c,'+
                        ' Customer__r.SalespersonNo__c'+
                    ' FROM Customer_Sales_History__c'+
                    ' WHERE Customer__c != null'+
                    ' AND FiscalPeriod__c != null'+
                    ' AND FiscalYear__c != null'+
                    ' AND Dollars_Sold__c != 0';



        this.goalMap = new Map<String,Goal__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }
   
    public void execute(Database.BatchableContext BC, List<sObject> scope){

        

        for (Customer_Sales_History__c csh :(List<Customer_Sales_History__c>)scope){
            
            if (csh.FiscalPeriod__c.isNumeric() == false || csh.FiscalYear__c.isNumeric() == false)
            	continue;
            
            if (Integer.valueOf(csh.FiscalYear__c) != Date.today().year())
                continue;

            String key = csh.Customer__r.SalespersonDivisionNo__c +'-'+ csh.Customer__r.SalespersonNo__c;

            if (goalMap.containsKey(key) == true){
                addDollars(goalMap.get(key),csh);
            } else {
                Goal__c goal = new Goal__c(External_Id__c = key,
                                           Name = csh.Customer__r.SalespersonNo__c,
                                           Actual_MTD_Sales__c = 0,
                                           X_YTD_Sales__c = 0,
                                           Actual_QTD_Sales__c = 0);
                

                addDollars(goal,csh);
                goalMap.put(key,goal);
            }
        }
    }

    private static void addDollars(Goal__c goal, Customer_Sales_History__c csh){
        Date today = Date.today();

        // check if fiscal is a number
        if (csh.FiscalPeriod__c.isNumeric() == false || csh.FiscalYear__c.isNumeric() == false)
            return;

        if (Integer.valueOf(csh.FiscalPeriod__c) == Date.today().month() && Integer.valueOf(csh.FiscalYear__c) == Date.today().year()){
            goal.Actual_MTD_Sales__c = goal.Actual_MTD_Sales__c + csh.Dollars_Sold__c;
        }

        if (Integer.valueOf(csh.FiscalYear__c) == Date.today().year()){
            goal.X_YTD_Sales__c = goal.X_YTD_Sales__c + csh.Dollars_Sold__c;
        }

        // 1 2 3, 4 5 6, 7 8 9, 10 11 12  Actual_QTD_Sales__c
        Set<Integer> quarterMonths = getQuarter();
        if (quarterMonths.contains(Integer.valueOf(csh.FiscalPeriod__c)) && Integer.valueOf(csh.FiscalYear__c) == Date.today().year()){
            goal.Actual_QTD_Sales__c = goal.Actual_QTD_Sales__c + csh.Dollars_Sold__c;
        }
    }

    private static Set<Integer> getQuarter(){
        Set<Integer> quarterMonths;// = new Set<Integer>();
        if (Date.today().month() >= 1 && Date.today().month() <= 3){
            quarterMonths = new Set<Integer>{1,2,3};
        } else if (Date.today().month() >= 4 && Date.today().month() <= 6){
            quarterMonths = new Set<Integer>{4,5,6};
        } else if (Date.today().month() >= 7 && Date.today().month() <= 9){
            quarterMonths = new Set<Integer>{7,8,9};
        } else if (Date.today().month() >= 10 && Date.today().month() <= 12){
            quarterMonths = new Set<Integer>{10,11,12};
        }
        return quarterMonths;
    }
   
    public void finish(Database.BatchableContext BC){

        Set<String> externalIds = new Set<String>();

        for (Goal__c goal : this.goalMap.values()){
            externalIds.add(goal.External_Id__c);
        }

        List<Goal__c> zeroGoalList = [SELECT Id FROM Goal__c WHERE External_Id__c NOT IN :externalIds];

        for (Goal__c goal : zeroGoalList){
            goal.Actual_MTD_Sales__c = 0;
            goal.X_YTD_Sales__c = 0;
            goal.Actual_QTD_Sales__c = 0;
        }

        try {
            update zeroGoalList;
        } catch (exception e){
            system.debug(e.getMessage());
        }

        try {
            upsert goalMap.values() External_Id__c;
        } catch (exception e){
            system.debug(e.getMessage());
        }

        Database.executeBatch(new GoalAccountBatch(), 10);
    }
}