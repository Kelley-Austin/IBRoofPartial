({
    doInit : function(component, event, helper) {
        // var pageReference = component.get("v.pageReference");
        // component.set("v.recordId", pageReference.state.c__refRecordId);
        console.log('recordId : '+component.get("v.recordId"));
        if(component.get("v.recordId").startsWith('001') == false){
            component.set('v.isglobalAction', true);
        }else{
            component.find("accountId").set("v.value", component.get("v.recordId"));
        }
        
        helper.getAccountDetails(component, event);
    },

    handleAccountSelection : function(component, event, helper){
        console.log('handleAccountSelection : '+component.find("accountId").get("v.value"));
        component.set("v.recordId",component.find("accountId").get("v.value"));
        helper.getAccountDetails(component, event);
    },

    handleAddressChange : function(component, event, helper){
        var qtObj = component.get("v.quoteObj");
        console.log('Address : '+qtObj.Shipping_Street__c+' '+qtObj.Shipping_City__c+' '+qtObj.Shipping_State_Province__c+' '+qtObj.Shipping_Country__c+' '+qtObj.Shipping_State_Province__c);
        console.log('postal code :: ',qtObj.Shipping_Zip_Postal_Code__c);
        if(qtObj.Shipping_Zip_Postal_Code__c){
            var action = component.get('c.getLocalTaxRates');
            action.setParams({
                quoteRec:qtObj
            });
            action.setCallback(this, function(r){
                var state = r.getState();
                if(state === 'SUCCESS'){
                    console.log('ReturnValue :: ', r.getReturnValue());
                    if(r.getReturnValue().hasOwnProperty('result')){
                        console.log('tax rate result :: ', JSON.parse(JSON.stringify(r.getReturnValue())));
                        console.log('taxRate :: ', JSON.parse(r.getReturnValue().result.taxRate));
                        let taxRate = (JSON.parse(r.getReturnValue().result.taxRate).totalRate)*100 + '\%';
                        component.set('v.localTaxRate', taxRate);
                    }else if(r.getReturnValue().hasOwnProperty('error')){
                        console.error(r.getReturnValue().error);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    // handleProjectSelection : function(component, event, helper){
    //     var lookupId = event.getParam("value")[0];
    //     console.log('project Id :: ', lookupId);
    //     var action = component.get('c.getProjectDetails');
    //     action.setParams({
    //         recId:lookupId
    //     });
    //     action.setCallback(this, function(r){
    //         var state = r.getState();
    //         if(state === 'SUCCESS'){
    //             console.log('ReturnValue :: ', r.getReturnValue());
    //             if(r.getReturnValue().hasOwnProperty('result')){
    //                 console.log('result :: ', r.getReturnValue().result);
    //                 console.log('taxRate :: ', JSON.parse(r.getReturnValue().result.taxRate));
    //                 console.log('shippingAdd :: ', r.getReturnValue().result.shippingAdd);
    //                 console.log((JSON.parse(r.getReturnValue().result.taxRate).totalRate)*100);
    //                 let taxRate = (JSON.parse(r.getReturnValue().result.taxRate).totalRate)*100 + '\%';
    //                 component.set('v.projectId', lookupId);
    //                 component.set('v.localTaxRate', taxRate);
    //             	component.set('v.shippingAdd',r.getReturnValue().result.shippingAdd);
    //                 component.set('v.projectDetail', r.getReturnValue().projectDetails);
    //                 console.log('project :: ', JSON.parse(JSON.stringify(component.get('v.projectDetail'))));
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    handleFilesChange : function(component, event, helper){
        var files = component.get('v.fileToBeUploaded');
        console.log('files :: ', files);
        
        if (files && files.length > 0) {
            var file = files[0][0];
            console.log('file :: ', file);

            if (file.size > 4500000) {
                component.set("v.fileName", 'Alert : File size cannot exceed 4500000 bytes.\n' + ' Selected file size: ' + file.size);
                component.set('v.showFileName', true);
                return;
            }

            if(file.name != ''){
                component.set('v.fileName', file.name);
            }
            var reader = new FileReader();
            reader.onload = function() {
                var fileContent = reader.result;
                var base64 = 'base64,';
                var dataStart = fileContent.indexOf(base64) + base64.length;
                fileContent = fileContent.substring(dataStart);
                var encodedFileContent = encodeURIComponent(fileContent);
                component.set('v.fileContent', encodedFileContent);
                // console.log('file Name :: ', component.get('v.fileName'));
                // console.log('file Content :: ', component.get('v.fileContent'));
                component.set('v.showFileName', true);
            }
            reader.readAsDataURL(file);

        }else{
            alert('no file attached');    
        }
    },

    handleSaveQuote : function(component, event, helper){
        // console.log('file Name :: ', component.get('v.fileName'));
        // console.log('file Content :: ', component.get('v.fileContent'));Local_Tax_Rate__c
        var localTax = component.get('v.localTaxRate');
        console.log('localTax $$ ', localTax);
        var qtObj = component.get("v.quoteObj");
        console.log('Quote : ', JSON.parse(JSON.stringify(qtObj)));
        if(qtObj.hasOwnProperty('Shipping_Street__c')){
            qtObj['ShippingStreet'] = qtObj.Shipping_Street__c;
        }
        if(qtObj.hasOwnProperty('Shipping_City__c')){
            qtObj['ShippingCity'] = qtObj.Shipping_City__c;
        }
        if(qtObj.hasOwnProperty('Shipping_State_Province__c')){
            qtObj['ShippingState'] = qtObj.Shipping_State_Province__c;
        }
        if(qtObj.hasOwnProperty('Shipping_Zip_Postal_Code__c')){
            qtObj['ShippingPostalCode'] = qtObj.Shipping_Zip_Postal_Code__c;
        }
        if(qtObj.hasOwnProperty('Shipping_Country__c')){
            qtObj['ShippingCountry'] = qtObj.Shipping_Country__c;
        }
        if(localTax){
            qtObj['Local_Tax_Rate__c'] = localTax;
        }
        console.log('Quote : ', JSON.parse(JSON.stringify(qtObj)));
        var action = component.get('c.saveNewQuote');
        action.setParams({
            "quoteRec":qtObj,
            "fileName": component.get('v.fileName'),
            "base64Data": component.get('v.fileContent')
        });
        
        action.setCallback(this, function(r){
            var state = r.getState();
            console.log('state : '+state);
            if(state === 'SUCCESS'){
                if(r.getReturnValue().hasOwnProperty('result')){
                    console.log('new quote :: ', r.getReturnValue().quoteId);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": r.getReturnValue().quoteId,
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                    if(component.get('v.isglobalAction')){
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }
                }
                if(r.getReturnValue().hasOwnProperty('error')){
                    console.log('ERROR : '+r.getReturnValue().quoteId);
                }
            }else{
                console.log('ERROR');
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCancel : function(component, event, helper){
        // var navEvt = $A.get("e.force:navigateToSObject");
        // navEvt.setParams({
        // "recordId": component.get("v.recordId"),
        // "slideDevName": "related"
        // });
        // navEvt.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

})