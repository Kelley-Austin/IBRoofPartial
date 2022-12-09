({
    getAccountDetails : function(component, event){
        var action = component.get('c.getAccountDetails');
        action.setParams({
            accId:component.get("v.recordId")
        });
        action.setCallback(this, function(r){
            var state = r.getState();
            if(state === 'SUCCESS'){
                if(r.getReturnValue().hasOwnProperty('result')){
                    component.set('v.quoteObj.Name', '');
                    component.set('v.quoteObj.AccountId', component.get("v.recordId"));
                    component.set('v.quoteObj.Account__c', component.get("v.recordId"));
                }
            }
        });
        $A.enqueueAction(action);
    }
})