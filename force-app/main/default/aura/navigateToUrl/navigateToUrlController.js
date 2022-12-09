({
    invoke : function(component, event, helper) {
        var redirectURL = component.get("v.redirectURL");
        var redirect = $A.get("e.force:navigateToURL");
        redirect.setParams({
           "url": redirectURL
        });
        redirect.fire();
    }
})