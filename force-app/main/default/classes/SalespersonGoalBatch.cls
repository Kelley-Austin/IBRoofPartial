global class SalespersonGoalBatch implements Database.Batchable<sObject>, Database.stateful, Schedulable {

    private String query;

    public SalespersonGoalBatch() {
        this.query = 'SELECT Id,'+
        ' User__c,'+
        ' SalespersonName__c,'+
        ' SalespersonNo__c, '+
        ' SalespersonDivisionNo__c,'+
            ' (SELECT Id,'+
                ' Jan_Goal__c,'+
                ' Feb_Goal__c,'+
                ' Mar_Goal__c,'+
                ' Apr_Goal__c,'+
                ' May_Goal__c,'+
                ' Jun_Goal__c,'+
                ' Jul_Goal__c,'+
                ' Aug_Goal__c,'+
                ' Sep_Goal__c,'+
                ' Oct_Goal__c,'+
                ' Nov_Goal__c,'+
                ' Dec_Goal__c,'+
                ' Jan_Quota__c,'+
                ' Feb_Quota__c,'+
                ' Mar_Quota__c,'+
                ' Apr_Quota__c,'+
                ' May_Quota__c,'+
                ' Jun_Quota__c,'+
                ' Jul_Quota__c,'+
                ' Aug_Quota__c,'+
                ' Sep_Quota__c,'+
                ' Oct_Quota__c,'+
                ' Nov_Quota__c,'+
                ' Dec_Quota__c,'+
                ' Yearly_Goal__c,'+
                ' Yearly_Quota__c'+
            ' FROM Sales_Plans__r)'+
        ' FROM Salesperson__c' +
        ' WHERE SalespersonNo__c Like \'0%\''; 
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }
   
    public void execute(Database.BatchableContext BC, List<sObject> scope){
 

        List<Goal__c> goalUpsertList = new List<Goal__c>();
        for (Salesperson__c salesperson : (List<Salesperson__c>) scope) {

            if (String.isBlank(salesperson.SalespersonDivisionNo__c) || String.isBlank(salesperson.SalespersonNo__c))
                continue;

            String key = salesperson.SalespersonDivisionNo__c + '-' + salesperson.SalespersonNo__c;


            Goal__c goal = new Goal__c(External_Id__c = key,
                                    Name = salesperson.SalespersonNo__c,
                                    Salesperson__c = salesperson.SalespersonName__c,
                                    Salesperson_ID__c = salesperson.SalespersonNo__c,
                                    Salesperson_Lookup__c = salesperson.Id,
                                    User__c = salesperson.User__c);


            if (salesperson.Sales_Plans__r.isEmpty() == false){
                calulateSalesPlan(goal, salesperson.Sales_Plans__r.get(0));
            }

            goalUpsertList.add(goal);
        }


        try {
            upsert goalUpsertList External_Id__c;
        } catch (exception e){
            system.debug(e.getMessage());
        }
    }

    public Static void calulateSalesPlan(Goal__c goal, Sales_Plan__c salesPlan){
        goal.Monthly_Goal__c = monthGoal(salesPlan, Date.today());
        goal.Month_Quota__c = monthQuota(salesPlan, Date.today());
        goal.Annual_Goal__c = yearGoal(salesPlan);
        goal.Annual_Quota__c = yearQuota(salesPlan);

    }

    public static Decimal monthGoal(Sales_Plan__c salesPlan, Date datetoday){

        if (datetoday.month() == 1){
            return salesPlan.Jan_Goal__c;
        } else if (datetoday.month() == 2){
            return salesPlan.Feb_Goal__c;
        } else if (datetoday.month() == 3){
            return salesPlan.Mar_Goal__c;
        } else if (datetoday.month() == 4){
            return salesPlan.Apr_Goal__c;
        } else if (datetoday.month() == 5){
            return salesPlan.May_Goal__c;
        } else if (datetoday.month() == 6){
            return salesPlan.Jun_Goal__c;
        } else if (datetoday.month() == 7){
            return salesPlan.Jul_Goal__c;
        } else if (datetoday.month() == 8){
            return salesPlan.Aug_Goal__c;
        } else if (datetoday.month() == 9){
            return salesPlan.Sep_Goal__c;
        } else if (datetoday.month() == 10){
            return salesPlan.Oct_Goal__c;
        } else if (datetoday.month() == 11){
            return salesPlan.Nov_Goal__c;
        } else if (datetoday.month() == 12){
            return salesPlan.Dec_Goal__c;
        }

        return 0;
    }
    public static Decimal monthQuota(Sales_Plan__c salesPlan, Date datetoday){

        if (datetoday.month() == 1){
            return salesPlan.Jan_Quota__c;
        } else if (datetoday.month() == 2){
            return salesPlan.Feb_Quota__c;
        } else if (datetoday.month() == 3){
            return salesPlan.Mar_Quota__c;
        } else if (datetoday.month() == 4){
            return salesPlan.Apr_Quota__c;
        } else if (datetoday.month() == 5){
            return salesPlan.May_Quota__c;
        } else if (datetoday.month() == 6){
            return salesPlan.Jun_Quota__c;
        } else if (datetoday.month() == 7){
            return salesPlan.Jul_Quota__c;
        } else if (datetoday.month() == 8){
            return salesPlan.Aug_Quota__c;
        } else if (datetoday.month() == 9){
            return salesPlan.Sep_Quota__c;
        } else if (datetoday.month() == 10){
            return salesPlan.Oct_Quota__c;
        } else if (datetoday.month() == 11){
            return salesPlan.Nov_Quota__c;
        } else if (datetoday.month() == 12){
            return salesPlan.Dec_Quota__c;
        }

        return 0;
    }
    
    @testVisible
    private static Decimal quarterGoal(Sales_Plan__c salesPlan, Date datetoday){
        
        Decimal quarterGoal = 0;
        
		switch on datetoday.month() {
            
			when 1, 2, 3 {
                
                if (salesPlan.Jan_Goal__c != null){
                    quarterGoal += salesPlan.Jan_Goal__c;
                }
                if (salesPlan.Feb_Goal__c != null){
                    quarterGoal += salesPlan.Feb_Goal__c;
                }
                if (salesPlan.Mar_Goal__c != null){
                    quarterGoal += salesPlan.Mar_Goal__c;
                }

			} when 4, 5, 6 {
                
                if (salesPlan.Apr_Goal__c != null){
                    quarterGoal += salesPlan.Apr_Goal__c;
                }
                if (salesPlan.May_Goal__c != null){
                    quarterGoal += salesPlan.May_Goal__c;
                }
                if (salesPlan.Jun_Goal__c != null){
                    quarterGoal += salesPlan.Jun_Goal__c;
                }
                
			} when 7, 8, 9 {
                
                if (salesPlan.Jul_Goal__c != null){
                    quarterGoal += salesPlan.Jul_Goal__c;
                }
                if (salesPlan.Aug_Goal__c != null){
                    quarterGoal += salesPlan.Aug_Goal__c;
                }
                if (salesPlan.Sep_Goal__c != null){
                    quarterGoal += salesPlan.Sep_Goal__c;
                }
                
            } when 10, 11, 12 {
                
				if (salesPlan.Oct_Goal__c != null){
                    quarterGoal += salesPlan.Oct_Goal__c;
                }
                if (salesPlan.Nov_Goal__c != null){
                    quarterGoal += salesPlan.Nov_Goal__c;
                }
                if (salesPlan.Dec_Goal__c != null){
                    quarterGoal += salesPlan.Dec_Goal__c;
                }
                
			} 
        }
        
        return quarterGoal;
    }
	
    @testVisible
	private static Decimal quarterQuota(Sales_Plan__c salesPlan, Date datetoday){
        
        Decimal quarterQuota = 0;
        
		switch on datetoday.month() {
            
			when 1, 2, 3 {
                
                if (salesPlan.Jan_Quota__c != null){
                    quarterQuota += salesPlan.Jan_Quota__c;
                }
                if (salesPlan.Feb_Quota__c != null){
                    quarterQuota += salesPlan.Feb_Quota__c;
                }
                if (salesPlan.Mar_Quota__c != null){
                    quarterQuota += salesPlan.Mar_Quota__c;
                }

			} when 4, 5, 6 {
                
                if (salesPlan.Apr_Quota__c != null){
                    quarterQuota += salesPlan.Apr_Quota__c;
                }
                if (salesPlan.May_Quota__c != null){
                    quarterQuota += salesPlan.May_Quota__c;
                }
                if (salesPlan.Jun_Quota__c != null){
                    quarterQuota += salesPlan.Jun_Quota__c;
                }
                
			} when 7, 8, 9 {
                
                if (salesPlan.Jul_Quota__c != null){
                    quarterQuota += salesPlan.Jul_Quota__c;
                }
                if (salesPlan.Aug_Quota__c != null){
                    quarterQuota += salesPlan.Aug_Quota__c;
                }
                if (salesPlan.Sep_Quota__c != null){
                    quarterQuota += salesPlan.Sep_Quota__c;
                }
                
            } when 10, 11, 12 {
                
				if (salesPlan.Oct_Quota__c != null){
                    quarterQuota += salesPlan.Oct_Quota__c;
                }
                if (salesPlan.Nov_Quota__c != null){
                    quarterQuota += salesPlan.Nov_Quota__c;
                }
                if (salesPlan.Dec_Quota__c != null){
                    quarterQuota += salesPlan.Dec_Quota__c;
                }
                
			} 
        }
        
        return quarterQuota;
        
    }
    
    public static Decimal yearGoal(Sales_Plan__c salesPlan){
        return salesPlan.Yearly_Goal__c;
    }
    public static Decimal yearQuota(Sales_Plan__c salesPlan){
        return salesPlan.Yearly_Quota__c;
    }

    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new GoalCalculationBatch(), 200); 
    }

    // System.schedule('SalespersonGoalBatchHourly', '0 0 * * * ?', new SalespersonGoalBatch());
    public void execute(SchedulableContext SC){
        Database.executeBatch(new SalespersonGoalBatch(), 100);
    }
    
}