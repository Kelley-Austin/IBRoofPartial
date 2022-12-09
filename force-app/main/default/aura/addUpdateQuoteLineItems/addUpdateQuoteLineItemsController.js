({
    doInit : function(component, event, helper) {
        var productFamily = [];
        component.set('v.spinnerQLI', true);
        component.set('v.showResult', true);
        //CALL getProductType() APEX METHOD TO GET PRODUCT TYPE LIST FOR COMBOBOX OR DROPDOWN//
        var action = component.get('c.getProductType');
        action.setParams({quoteId:component.get("v.recordId")});
        action.setCallback(this, function(r){
            var state = r.getState();
            if(state === 'SUCCESS'){
                console.log('result :: ', r.getReturnValue());
                if(r.getReturnValue().hasOwnProperty('accountName'));{
                    component.set("v.accountName", r.getReturnValue().AccountName);
                }
                if(r.getReturnValue().hasOwnProperty('quoteLineItem'));{
                    component.set("v.quoteItems", r.getReturnValue().quoteLineItem);
                    component.set("v.opptyRecordId", r.getReturnValue().opptyId);
                }
                if(r.getReturnValue().hasOwnProperty('pfamily')){
                    let pfc = [];
                    let pf = [];
                    pf.push(Object.assign({}, {label:'--Select--', value:''}));
                    for( var key in r.getReturnValue().pfamily){
                        if(r.getReturnValue().pfamily[key].includes('CUSTOM')){
                            pfc.push(Object.assign({}, {label:r.getReturnValue().pfamily[key], value:r.getReturnValue().pfamily[key]}));
                        }else {
                            pf.push(Object.assign({}, {label:r.getReturnValue().pfamily[key], value:r.getReturnValue().pfamily[key]}));
                        }
                        //productFamily.push(Object.assign({}, {label:r.getReturnValue().pfamily[key], value:r.getReturnValue().pfamily[key]}));
                    }
                    if(pf.length>0){
                        if(pfc.length > 0){
                     		pf = [...pf,...pfc];
                        }
                        component.set("v.productTypeList", pf);
                    }
                    if(pf.length>0){
                        
                    }
                }else if(r.getReturnValue().hasOwnProperty('error')){
                    console.log('Error ##... ', r.getReturnValue().error);
                }
            }else if(state === 'ERROR'){
                console.log('Action Callback State ## ', state);
            }
            component.set('v.spinnerQLI', false);
        });
        $A.enqueueAction(action);
    },
    
    //SHOW PRODUCT LISTS AS TABLE ACCORDING TO SELECTED PRODUCT TYPE//
    handlePdcTypeSelected : function(component, event, helper){
        //var searchStr = component.find('skuSearch').set("v.value",'');
        var searchStr = component.find('skuSearch');
        if(searchStr){
            searchStr.set("v.value",'');
        }
        component.set('v.spinnerQLI', true);
        var ptype = component.find('productFamily').get("v.value");
        var pTypeList = component.get('v.selectedProductType');
        var productDetailsToStore = component.get('v.productDetailsToStore');
        if(!ptype.includes('CUSTOM') && ptype){
            if(!component.get('v.hasNonCustomBlock')){
                component.set('v.hasNonCustomBlock', true);
            }
            if(!pTypeList.includes(ptype)){
                // first time product type selected //
                var action = component.get('c.getProductByType');
                action.setParams({
                    productType:component.find('productFamily').get("v.value")
                });
                action.setCallback(this, function(r){
                    var state = r.getState();
                    if(state === 'SUCCESS'){
                        if(r.getReturnValue().hasOwnProperty('result')){
                            //console.log('productList result ## ', r.getReturnValue().result);
                            for(let key in r.getReturnValue().result){
                                r.getReturnValue().result[key]['ListPrice'] = r.getReturnValue().result[key]['UnitPrice'];
                            }
                            //console.log('productList result ## ', r.getReturnValue().result);
                            component.set('v.productList',r.getReturnValue().result);
                            helper.distributeData(component, component.get('v.productList'));
                            let storePdcList = [];
                            let storePdc = Object.assign({}, {ptype:ptype, record:r.getReturnValue().result});
                            if(productDetailsToStore.length>0){
                                storePdcList = productDetailsToStore;
                                storePdcList.push(storePdc);
                                component.set('v.productDetailsToStore', storePdcList);
                            }else{
                                component.set('v.productDetailsToStore', storePdc);
                            }
                            if(pTypeList.length>0){
                                let arr = [];
                                arr = pTypeList;
                                arr.push(ptype);
                                component.set('v.selectedProductType', arr);
                            }else{
                                component.set('v.selectedProductType', ptype);
                            }
                        }
                    }else if(state === 'ERROR'){
                        console.log('Action Callback State ## ', state);
                    }
                });
                $A.enqueueAction(action);
            }else if(pTypeList.includes(ptype)){
                //prodcut type already selected before//
                for(var key in productDetailsToStore){
                    if(productDetailsToStore[key].ptype == ptype){
                        component.set('v.productList',productDetailsToStore[key].record);
                        helper.distributeData(component, component.get('v.productList'));
                    }
                }
            }
        }else if(ptype.includes('CUSTOM') && ptype){
            if(component.get('v.hasNonCustomBlock')){
                component.set('v.hasNonCustomBlock', false);
            }
            component.set('v.hasCustomProducts', false);
            component.set('v.img', '');
            component.set('v.pType', ptype);
            component.set('v.customProductList',[]);
            helper.handleCustomProductType(component, ptype);
        }else if(!ptype){
            component.set('v.showResult', false);
        }
        component.set('v.spinnerQLI', false);
    },
    
    //FILTER PRODUCT LIST ACCORDING TO PRODUCTNAME, COLOR, SIZE//
    handleOptionChange : function(component, event, helper){
    	var pdcType = component.find('productFamily').get("v.value");
        var pdcName = component.find('productName').get("v.value");
        var pdcColor = component.find('productColor').get("v.value");
        var pdcSize = component.find('productSize').get("v.value");
        var pdcThickness = component.find('productThickness').get("v.value");
        var pdcDetailsList = JSON.parse(JSON.stringify(component.get('v.productDetailsToStore')));
        var pdcDetails = [];
        var filterArr = [];
        if(pdcName){
            filterArr.push('Name');
        }
        if(pdcColor){
            filterArr.push('Color_2__c');
        }
        if(pdcSize){
            filterArr.push('Product_Size_2__c');
        }
        if(pdcThickness){
            filterArr.push('Thickness_2__c');
        }
        for(var key in pdcDetailsList){
            if(pdcDetailsList[key].ptype === pdcType){
                pdcDetails = pdcDetailsList[key].record;
            }
        }
        if(pdcDetails.length>0 && pdcType != 'CUSTOM'){
            if(filterArr.length){
               // console.log('filterArr ', filterArr);
                let pName;
                let pColor;
                let pSize;
                let pThickness;
                if(filterArr.length == 1){
                    let f = filterArr[0];
                    let fVal = filterArr[0] == 'Name' ? pdcName : filterArr[0] == 'Color_2__c' ? pdcColor : filterArr[0] == 'Product_Size_2__c' ? pdcSize : pdcThickness;
                    const p = pdcDetails.filter(item => item.Product2[f] == fVal);
                    console.log(p);
                    component.set('v.productList',p);
                    helper.reAssignOptions(component, p);
                }else if(filterArr.length == 2){
                    let f1 = filterArr[0]; let f2 = filterArr[1]; 
                    let fVal1 = filterArr[0] == 'Name' ? pdcName : filterArr[0] == 'Color_2__c' ? pdcColor : filterArr[0] == 'Product_Size_2__c' ? pdcSize : pdcThickness;
                    let fVal2 = filterArr[1] == 'Name' ? pdcName : filterArr[1] == 'Color_2__c' ? pdcColor : filterArr[1] == 'Product_Size_2__c' ? pdcSize : pdcThickness;
                    const p = pdcDetails.filter(item => item.Product2[f1] == fVal1 && item.Product2[f2] == fVal2);
               		component.set('v.productList',p);
                    helper.reAssignOptions(component, p);
                }else if(filterArr.length == 3){
                    let f1 = filterArr[0]; let f2 = filterArr[1]; let f3 = filterArr[2]; 
                    let fVal1 = filterArr[0] == 'Name' ? pdcName : filterArr[0] == 'Color_2__c' ? pdcColor : filterArr[0] == 'Product_Size_2__c' ? pdcSize : pdcThickness;
                    let fVal2 = filterArr[1] == 'Name' ? pdcName : filterArr[1] == 'Color_2__c' ? pdcColor : filterArr[1] == 'Product_Size_2__c' ? pdcSize : pdcThickness;
                    let fVal3 = filterArr[2] == 'Name' ? pdcName : filterArr[2] == 'Color_2__c' ? pdcColor : filterArr[2] == 'Product_Size_2__c' ? pdcSize : pdcThickness;
                    const p = pdcDetails.filter(item => item.Product2[f1] == fVal1 && item.Product2[f2] == fVal2  && item.Product2[f3] == fVal3);
               		component.set('v.productList',p);
                    helper.reAssignOptions(component, p);
                }else if(filterArr.length == 4){
                    const p = pdcDetails.filter(item => item.Product2.Name == pdcName && item.Product2.Color_2__c == pdcColor && item.Product2.Product_Size_2__c == pdcSize && item.Product2.Thickness_2__c == pdcThickness);
                	component.set('v.productList',p);
                    helper.reAssignOptions(component, p);
                }
            }else if(filterArr.length == 0){
                    component.set('v.productList',pdcDetails);
                    helper.reAssignOptions(component, pdcDetails);
                }
            filterArr = [];
        }else{
            helper.handleCustomProductType(component, event, helper);
        }
	},
    
    //SEARCH PRODUCT ACCORDING TO SEARCH BAR //
	searchSKU : function(component, event, helper){
        component.set('v.showResult', true);
        var pdcType = component.find('productFamily').get("v.value");
        var pdcName = component.find('productName').get("v.value");
        var pdcColor = component.find('productColor').get("v.value");
        var pdcSize = component.find('productSize').get("v.value");        
        //console.log(event. getSource(). get("v.name"));
        var obj;
        var hasSearchStr = true;
        if(event. getSource(). get("v.name") === "skuSearchBtn"){
            let searchStr = component.find('skuSearch').get("v.value");
            component.set("v.pNameSearchValue","");
            if(searchStr){
                obj = {
                    'pdcType' : pdcType,
                    'pdcName' : pdcName,
                    'pdcColor' : pdcColor,
                    'pdcSize' : pdcSize,
                    'searchStr' : searchStr
                };
            }else{
                hasSearchStr = false;
            }
        }else if(event. getSource(). get("v.name") === "pNameSearchBtn"){
            let searchStr = component.find('pNameSearch').get("v.value");
            component.set("v.skuSearchValue","");
            if(searchStr){
                obj = {
                    'pdcType' : '',
                    'pdcName' : searchStr,
                    'pdcColor' : '',
                    'pdcSize' : '',
                    'searchStr' : ''
                };
            }else{
                hasSearchStr = false;
            }
        }
        //console.log('Search String : : ', searchStr);
        if((pdcType != 'CUSTOM') && hasSearchStr){
            /*var obj = {
                'pdcType' : pdcType,
                'pdcName' : pdcName,
                'pdcColor' : pdcColor,
                'pdcSize' : pdcSize,
                'searchStr' : searchStr
            };*/
            var action = component.get('c.getProductBySearchTerm');
            console.log('search :: ', JSON.stringify(obj));
            action.setParams({
                searchStr:JSON.stringify(obj)
            });
            action.setCallback(this, function(r){
                var state = r.getState();
                if(state === 'SUCCESS'){
                    if(r.getReturnValue().hasOwnProperty('result')){
                        console.log('result :: ', r.getReturnValue().result);
                        r.getReturnValue().result.forEach(item =>{item['ListPrice'] = item['UnitPrice']});
                    };
                    console.log('Result :: ', r.getReturnValue().result);
                    component.set('v.productList',r.getReturnValue().result);
                }else if(state === 'ERROR'){
                    console.log('Action Callback State ## ', state);
                }
            });
            $A.enqueueAction(action);
                                                                 }else{
                                                                  component.set('v.productList',[]);
                                                                 }
    },
    
    
    //ADD PRODUCT(QUOTE LINE ITEM) TO QUOTE
    addProduct : function(component, event, helper){
        var specialNotesB = component.find('specialNotesB');
        var quantityB = component.find('quantityB');
        var unitpriceB = component.find('unitpriceB');
        var row = event.getSource().get("v.name");
        var color = component.find('clr');
        var clr ='';
        //Array.isArray(color) ? (clr = color[row].get("v.value")) : (clr = color.get("v.value"));
        var detail = JSON.parse(JSON.stringify(component.get('v.productList')));
        console.log('detail :: ', detail);
        console.log('specialNotesB :: ', specialNotesB);
        var selectPdc = detail[row];
        clr = selectPdc.Product2['Color_2__c'];
        console.log('color $$ ', clr);
        var quoteItemList = [];
        var quoteItem = [];
        quoteItem = component.get('v.quoteItems');
        var addedItem = detail[row];
        
        //CREATE QUOTE LINE ITEM VALUES AS MAP TO INSERT NEW QUOTE LINE ITEM//
        var addQuoteLineItem = {};
        if(specialNotesB){
            let sn;
            Array.isArray(specialNotesB) ? (sn=specialNotesB[row].get("v.value")) : (sn=specialNotesB.get("v.value"));
            console.log('Special Notes ::', sn);
            Object.assign(addQuoteLineItem, {'Description': sn});
            Array.isArray(specialNotesB) ? specialNotesB[row].set("v.value", '') : specialNotesB.set("v.value", '');
        }  
        if(quantityB){
            let quantity;
            Array.isArray(quantityB) ? (quantity=quantityB[row].get("v.value")) : (quantity=quantityB.get("v.value"));
            console.log('quantity ::', quantity);
            Object.assign(addQuoteLineItem, {'Quantity': quantity});
            Array.isArray(quantityB) ? quantityB[row].set("v.value", '') : quantityB.set("v.value", '');
        }
        if(unitpriceB){
            let up;
            Array.isArray(unitpriceB) ? (up=unitpriceB[row].get("v.value")) : (up=unitpriceB.get("v.value"));
            Object.assign(addQuoteLineItem, {'UnitPrice': up});
        }
        Object.assign(addQuoteLineItem, {'OpportunityLineItemId': component.get('v.opptyRecordId')});
        Object.assign(addQuoteLineItem, {'PricebookEntryId': addedItem.Id});
        Object.assign(addQuoteLineItem, {'Product2Id': addedItem.Product2.Id});
        Object.assign(addQuoteLineItem, {'QuoteId': component.get('v.recordId')});
        Object.assign(addQuoteLineItem, {'Product_Color__c': clr});
        
        //CALL addQuoteLineItem APEX METHOD TO INSERT NEW QUOTE LINE ITEM//
        console.log('addQuoteLineItem :: ', addQuoteLineItem);
        var action = component.get('c.addQuoteLineItem');
        action.setParams({recordDetails:JSON.stringify(addQuoteLineItem),  findProductData:''});
        action.setCallback(this, function(r){
            var state = r.getState();
            if(state === 'SUCCESS'){
                console.log('result :: ', r.getReturnValue());
                if(r.getReturnValue().hasOwnProperty('newQuoteLineItem')){
                    let newQLI = JSON.parse(JSON.stringify(r.getReturnValue().newQuoteLineItem));
                    //CHECK IF QUOTELINEITEM SECTION HAS LIST OR NOT
                    if(quoteItem !== undefined){
                        quoteItemList = quoteItem ;
                        quoteItemList.push(newQLI);
                        component.set('v.quoteItems', quoteItemList);
                    }else{
                        component.set('v.quoteItems', newQLI);
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Product has been added successfully.",
                        "type":"success"
                    });
                    toastEvent.fire();
                }
            }else if(state === 'ERROR'){
                console.log('Action Callback State ## ', state);
                let errorMsg = r.getError()[0]['fieldErrors']['Quantity'][0]['message'];
                console.log('ERROR ## ', r.getError()[0]['fieldErrors']['Quantity'][0]['message']);
                console.log('ERROR RESULT :: ', r.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": errorMsg,
                        "type":"Error"
                    });
                    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    //REMOVE QUOTE LINE ITEM FROM UI AND PERFORM DELETE DML OPERATION//
    removeQLI : function(component, event, helper){
        var row = event.getSource().get("v.name");
        var quoteItem = JSON.parse(JSON.stringify(component.get('v.quoteItems')));
        var removeQLI = quoteItem[row]
        var action = component.get('c.deleteQuoteLineItem');
        action.setParams({recordId:removeQLI.Id, quoteId:component.get('v.recordId')});
        action.setCallback(this, function(r){
            var state = r.getState();
            console.log('state :: ', state);
            if(state === 'SUCCESS'){
                quoteItem.splice(row, 1);
                component.set('v.quoteItems', quoteItem);
            }else if(state === 'ERROR'){
                console.log('Action Callback State ## ', state);
            }
        });
        $A.enqueueAction(action);
    },
    
    editQLI : function(component, event, helper){
        var row = event.getSource().get("v.name");
        var quoteItem = JSON.parse(JSON.stringify(component.get('v.quoteItems')));
        
        //enable quoteLineItem input field for edit//
        var specialNotesB = component.find('specialNotes');
        var quantityB = component.find('quantity');
        var unitpriceB = component.find('unitprice');
        Array.isArray(specialNotesB) ? (specialNotesB[row].set("v.disabled", false)) : (specialNotesB.set("v.disabled", false));
        Array.isArray(quantityB) ? (quantityB[row].set("v.disabled", false)) : (quantityB.set("v.disabled", false));
        Array.isArray(unitpriceB) ? (unitpriceB[row].set("v.disabled", false)) : (unitpriceB.set("v.disabled", false));
        
        //toggel editIcon and checkIcon
        var editIconRows = component.find('editIcon');
        var saveIconRows = component.find('checkIcon');
        //console.log('editIconRows :: ', editIconRows);
        var editIconRow;
        var saveIconRow;
        Array.isArray(editIconRows) ? (editIconRow=editIconRows[row]) : (editIconRow=editIconRows);
        Array.isArray(saveIconRows) ? (saveIconRow=saveIconRows[row]) : (saveIconRow=saveIconRows);
        Array.isArray(editIconRows) ? (editIconRow=editIconRows[row]) : (editIconRow=editIconRows);
        Array.isArray(saveIconRows) ? (saveIconRow=saveIconRows[row]) : (saveIconRow=saveIconRows);
        $A.util.removeClass(editIconRow, "slds-show");
        $A.util.addClass(editIconRow, "slds-hide");
        $A.util.removeClass(saveIconRow, "slds-hide");
        $A.util.addClass(saveIconRow, "slds-show");
    },
    
    saveQLI : function(component, event, helper){
        var row = event.getSource().get("v.name");
        var quoteItem = JSON.parse(JSON.stringify(component.get('v.quoteItems')));
        var qliToUpdate = {};
        Object.assign(qliToUpdate,{'Id': quoteItem[row].Id});
        
        //GET quoteLineItem's EDIT VALUES FROM INPUT FIELD
        var specialNotesB = component.find('specialNotes');
        var quantityB = component.find('quantity');
        var unitpriceB = component.find('unitprice');
        let sn;
        Array.isArray(specialNotesB) ? (sn=specialNotesB[row].get("v.value")) : (sn=specialNotesB.get("v.value"));
        Object.assign(qliToUpdate,{'specialNotes': sn});
        let quantity;
        Array.isArray(quantityB) ? (quantity=quantityB[row].get("v.value")) : (quantity=quantityB.get("v.value"));
        Object.assign(qliToUpdate,{'quantity': quantity});
        let up;
        Array.isArray(unitpriceB) ? (up=unitpriceB[row].get("v.value")) : (up=unitpriceB.get("v.value"));
        Object.assign(qliToUpdate,{'unitprice': up});
        
        var dataToPass = JSON.stringify(qliToUpdate);
       // console.log('dataToPass :: ', dataToPass);
        var action = component.get('c.updateQuoteLineItem');
        action.setParams({qliToUpdate:dataToPass,quoteId:component.get('v.recordId')});
        action.setCallback(this, function(r){
            var state = r.getState();
            if(state === 'SUCCESS'){
               // console.log('r.getReturnValue :: ', r.getReturnValue());
                if(r.getReturnValue().hasOwnProperty('success')){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Updated Successfully.",
                        "type":"success"
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Can Not Update The Record.",
                        "type":"error"
                    });
                    toastEvent.fire();
                }
            }else if(state === 'ERROR'){
                console.log('Action Callback State ## ', state);
            }
        });
        $A.enqueueAction(action);
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
        //toggel editIcon and checkIcon
        var editIconRows = component.find('editIcon');
        var saveIconRows = component.find('checkIcon');
        var editIconRow;
        var saveIconRow;
        Array.isArray(editIconRows) ? (editIconRow=editIconRows[row]) : (editIconRow=editIconRows);
        Array.isArray(saveIconRows) ? (saveIconRow=saveIconRows[row]) : (saveIconRow=saveIconRows);
        $A.util.removeClass(editIconRow, "slds-hide");
        $A.util.addClass(editIconRow, "slds-show");
        $A.util.removeClass(saveIconRow, "slds-show");
        $A.util.addClass(saveIconRow, "slds-hide");
    },
    
    handleCustomProductInput : function(component, event ,helper){ 
        var fieldApiName = event.getSource().get('v.name');
        var fieldVal = event.getSource().get('v.value');
        var fpObj = component.get('v.findProductObject');
        var obj = {};
        obj[fieldApiName] = fieldVal;
        Object.assign(fpObj, obj);
    },
        
    handleFindCustomProduct : function(component, event ,helper){
       // console.log('findProductObject :: ', component.get('v.findProductObject'));
        var findProductValues = JSON.parse(JSON.stringify(component.get('v.findProductObject')));
       // console.log('findProductObject :: ', findProductValues);
        var findInputVal = component.find('cusInput');
        var findInputValList = [];
        var hasRequiredFieldNull = false;
        Array.isArray(findInputVal) ? (findInputValList = findInputVal) : (findInputValList.pust(findInputVal));
        for(let key in findInputValList){
            console.log(findInputValList[key].get('v.value'));
            if(findInputValList[key].get('v.required') == true && findInputValList[key].get('v.value')==''){
                hasRequiredFieldNull = true;
                findInputValList[key].focus();
                findInputValList[key].blur();
            }
        }
        if(!hasRequiredFieldNull){
            component.set('v.spinnercustomPdc', true);
            var ptype = component.find('productFamily').get("v.value");
            var pdcSelectionCriteria = '';
            var findPdcVal = component.get('v.findProductObject');
            if(findPdcVal.hasOwnProperty('Product_Selection_Where__c')){
                pdcSelectionCriteria = findPdcVal['Product_Selection_Where__c'];
                delete findPdcVal['Product_Selection_Where__c'];
            }
            var action = component.get('c.getCustomAddProductFields');
            action.setParams({
                quoteId: component.get('v.recordId'),
                //productCriteria: pdcSelectionCriteria,
                customProductType: ptype,
                findPdcVal: JSON.stringify(findPdcVal)
            });
            action.setCallback(this, function(r){
                var state = r.getState();
                if(state === 'SUCCESS'){
                    if(r.getReturnValue().hasOwnProperty('customAddProductFields')){
                        console.log('Result :: ', r.getReturnValue());
                        let CusTableColumns;
                        console.log(Number(r.getReturnValue().customAddProductType.Columns__c));
                        if((Number(r.getReturnValue().customAddProductType.Columns__c)) && (Number(r.getReturnValue().customAddProductType.Columns__c))>=0){
                            CusTableColumns = parseInt(12/(Number(r.getReturnValue().customAddProductType.Columns__c)), 10);
                            component.set('v.customTableColumns', CusTableColumns);
                        }
                        console.log('columns $$ ', CusTableColumns);
                        component.set('v.customAddProductFields', r.getReturnValue().customAddProductFields);
                        component.set('v.hasCustomProducts', true);
                        component.set('v.searchResult', r.getReturnValue().searchResult);
                        helper.distributeCustomProductData(component, r.getReturnValue().customAddProductFields, r.getReturnValue().searchResult);
                        component.set('v.spinnercustomPdc', false);
                        component.set('v.hasCustomProducts', true);
                    }else if(r.getReturnValue().hasOwnProperty('error')){
                        component.set('v.spinnercustomPdc', false);
                        component.set('v.hasCustomProducts', false);
                        console.log('error :: ', r.getReturnValue().error);
                    }
                }else if(state === 'ERROR'){
                    component.set('v.spinnercustomPdc', false);
                    component.set('v.hasCustomProducts', false);
                    console.log('Action Callback State ## ', state);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    handleAddCustomProduct : function(component, event ,helper){        
        var pdRow = event.getSource().get('v.name');
        var getProductRows = component.find('rowCol');
        var totalPdc = component.get('v.customProductList');
        var isQuantityNull = false;
        //CHECK IF REQUIRED FIELD IS NULL OR NOT
        getProductRows.forEach((item, index)=>{
            if(item.get('v.required') && item.get('v.name') == pdRow && !item.get('v.readonly')){
            	if(item.get('v.value') ==''){
            		getProductRows[index].focus();
            		getProductRows[index].blur();
            		isQuantityNull = true;
        		}else{
                    isQuantityNull = false;      
                }
        	}
        });
        var customPdList = component.get('v.customProductList')[pdRow];
        console.log('customPdList $$ ', customPdList);
        var newcustomPdList = [];
        if(customPdList.hasOwnProperty('standPdc')){
            let standPdc = customPdList['standPdc'];
            standPdc.forEach(item=>{
                newcustomPdList.push(item);
            });
        }
        if(customPdList.hasOwnProperty('cusPdc')){
            let cusPdc = customPdList['cusPdc'];
            cusPdc.forEach(item=>{
                newcustomPdList.push(item);
            });
        }
		console.log('newcustomPdList $$ ', newcustomPdList);
        customPdList = newcustomPdList;
        var findProductData = JSON.parse(JSON.stringify(component.get('v.findProductObject')));
        if(findProductData.hasOwnProperty('Product_Selection_Where__c')){
            delete findProductData['Product_Selection_Where__c'];
        }
        var objToPass={};
        for(let key in customPdList){
            let fieldApiName = customPdList[key]['Field_API_Name__c'];
            let fieldValue = customPdList[key]['value'];
            var pdcType = component.find('productFamily').get("v.value");
            if(pdcType == 'CUSTOM DRIP EDGE WHITE'){
               objToPass['Product_Color__c'] = 'White';
            }else if(pdcType == 'CUSTOM DRIP EDGE STAINLESS'){
                	objToPass['Product_Color__c'] = 'STAINLESS';
            }else if(pdcType == 'CUSTOM GALVANIZED CLEAT'){
                	objToPass['Product_Color__c'] = 'GALVANIZED CLEAT';
            }else if(pdcType == 'CUSTOM STAINLESS CLEAT'){
                	objToPass['Product_Color__c'] = 'STAINLESS CLEAT';
            }else if(fieldApiName == 'Product2.Color_2__c' && !findProductData.hasOwnProperty('Product_Color__c')){
                	objToPass['Product_Color__c'] = fieldValue;
            }
            if(!fieldApiName.includes('Product2.'))
            	objToPass[fieldApiName] = fieldValue;
        }
        if(!isQuantityNull){
            var record = component.get('v.searchResult')[pdRow];
            var dataToPass;
            if(record['pbe'].Product2Id == customPdList[0]['idsToMap']['Product2Id']){
                dataToPass = Object.assign(record['qli'], objToPass);
            }
            var newObj = {};
            Object.getOwnPropertyNames(dataToPass).forEach((item, index)=> {
                newObj[item] = dataToPass[item].toString();
            });
                newObj['OpportunityLineItemId'] = component.get('v.opptyRecordId');
                Object.assign(newObj, findProductData);
                console.log('newObj $$ ', newObj);
                var addQuoteLineItem = JSON.stringify(newObj);
                
                var quoteItemList = [];
                var quoteItem = [];
                quoteItem = component.get('v.quoteItems');
                var action = component.get('c.addQuoteLineItem');
                action.setParams({recordDetails:addQuoteLineItem, findProductData:JSON.stringify(findProductData)});
            action.setCallback(this, function(r){
                var state = r.getState();
                if(state === 'SUCCESS'){
                    console.log('result :: ', r.getReturnValue());
                    if(r.getReturnValue().hasOwnProperty('newQuoteLineItem')){
                        let newQLI = JSON.parse(JSON.stringify(r.getReturnValue().newQuoteLineItem));
                        //CHECK IF QUOTELINEITEM SECTION HAS LIST OR NOT
                        if(quoteItem !== undefined){
                            quoteItemList = quoteItem ;
                            quoteItemList.push(newQLI);
                            component.set('v.quoteItems', quoteItemList);
                        }else{
                            component.set('v.quoteItems', newQLI);
                        }
                    }
                }else if(state === 'ERROR'){
                    console.log('Action Callback State ## ', state);
                }
            });
            $A.enqueueAction(action);
        }
    }
})