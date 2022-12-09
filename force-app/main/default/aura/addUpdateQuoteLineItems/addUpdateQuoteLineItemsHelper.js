({
    handleCustomProductType : function(component, ptype){
        var action = component.get('c.getCustomFindProductFields');
        action.setParams({
            customProductType : ptype
        });
        action.setCallback(this, function(r){
            var state = r.getState();
            if(state === 'SUCCESS'){
                //console.log('result :: ', r.getReturnValue());
                if(r.getReturnValue().hasOwnProperty('customFindProductType')){
                    component.set('v.img', r.getReturnValue().customFindProductType.Diagram__c);
                    //component.set('v.productSelectionCriteria', r.getReturnValue().customFindProductType.Product_Selection_Where__c);
                    component.set('v.findProductObject', {'Product_Selection_Where__c':r.getReturnValue().customFindProductType.Product_Selection_Where__c});
                    //console.log(JSON.parse(JSON.stringify(component.get('v.findProductObject'))));
                    
                    let columns = parseInt(12 / r.getReturnValue().customFindProductType.Columns__c, 10);
                    if(columns){
                        if(columns < 12){
                            component.set('v.labelPosition', 'label-stacked');
                            component.set('v.columns', columns);
                        }else if(columns == 12){
                            component.set('v.labelPosition', 'label-inline');
                            component.set('v.columns', columns);
                        }
                    }else {
                        if(r.getReturnValue().customFindProductFields.length > 6){
                            component.set('v.labelPosition', 'label-stacked');
                            component.set('v.columns', 6);
                        }else if(r.getReturnValue().customFindProductFields.length < 6){
                            component.set('v.labelPosition', 'label-inline');
                            component.set('v.columns', 12);
                        }
                    }
                    if(r.getReturnValue().hasOwnProperty('customFindProductFields')){
                       // console.log('CustomProductFields :: ', r.getReturnValue().customFindProductFields);
                        let productFindFields = r.getReturnValue().customFindProductFields;
                        for(let key in productFindFields){
                            if(productFindFields[key].hasOwnProperty('Picklist_Values__c')){
                                var pickListval = productFindFields[key].Picklist_Values__c;
                                if(pickListval.indexOf(',') !== -1){
                                    var splitValList = pickListval.split(',');
                                    var pickListObjectList = [];
                                    pickListObjectList.push({label:'--Select--', value:''});
                                    splitValList.forEach(i=>{let pickListObject = Object.assign({},{label:i.trim(), value:i.trim()}); pickListObjectList.push(pickListObject);});
                                Object.assign(productFindFields[key],{Picklist_Values__c:pickListObjectList});
                                Object.assign(productFindFields[key],{'hasPickListValues':true});
                            }
                        }else{
                            Object.assign(productFindFields[key],{'hasPickListValues':false});
                        }
                    }
                   // console.log('productFindFields :: ', productFindFields);
                    component.set('v.CustomFindProductFields', productFindFields);
                }
            }else if(r.getReturnValue().hasOwnProperty('error')){
                    console.log('error :: ', r.getReturnValue().error);
                }
            }else if(state === 'ERROR'){
                console.log('Action Callback State ## ', state);
            }
        });
        $A.enqueueAction(action);
    },
    
    distributeCustomProductData : function(component, fieldsList, customProdList){
       // console.log('fieldsList :: ', fieldsList);
       // console.log('customProductList :: ', customProdList);
       	var pdcType = component.find('productFamily').get("v.value");
        var productToShowList = [];
    	var findProductObject = component.get('v.findProductObject');
        for(let cKey in customProdList){
            let customProductList = customProdList[cKey]['pbe'];
            let tempProductToShowList = [];
            console.log(fieldsList);
            for(let fKey in fieldsList){
                let idsToMap = {
                    'PriceBookEntryId': customProductList['Id'],
                    'Product2Id':customProductList['Product2Id'],
                    'PriceBook2Id':customProductList['Pricebook2Id'],
                    'QuoteId':component.get('v.recordId')
                };
                let fieldApiName = fieldsList[fKey]['Field_API_Name__c'];
                if(fieldApiName.includes('Product2.')){
                    fieldApiName = fieldApiName.replace('Product2.','');
                }
                console.log('fieldApiName :: ', fieldApiName);
                let NewValueToAssign = {};
                if(customProductList.Product2.hasOwnProperty(fieldApiName) && fieldApiName!= 'Color_2__c'){
                    NewValueToAssign = {'value':customProductList.Product2[fieldApiName]};
                }
                else if(customProductList.hasOwnProperty(fieldApiName) && fieldApiName!= 'Color_2__c'){
                    NewValueToAssign = {'value':customProductList[fieldApiName]};
                } else{
                    if(fieldApiName != 'ListPrice' && fieldApiName != 'Color_2__c'){
                    	NewValueToAssign = {'value':''}; 
                    }else if(fieldApiName == 'ListPrice'){
                        NewValueToAssign = {'value':customProductList['UnitPrice']}; 
                    }
                    if(fieldApiName == 'Color_2__c' && findProductObject.hasOwnProperty('Product_Color__c')){
                        NewValueToAssign = {'value':findProductObject['Product_Color__c']};
                        //NewValueToAssign['Color__c'] = findProductObject['Product_Color__c'];
                    }else if(fieldApiName == 'Color_2__c' && findProductObject.hasOwnProperty('Color_Metal__c')){
                        NewValueToAssign = {'value':findProductObject['Color_Metal__c']};
                        //NewValueToAssign['Product_Color__c'] = findProductObject['Color_Metal__c'];
                    }else if(fieldApiName == 'Color_2__c' && pdcType == 'CUSTOM DRIP EDGE WHITE'){
                        NewValueToAssign = {'value':'WHITE'};
                    }else if(fieldApiName == 'Color_2__c' && pdcType == 'CUSTOM DRIP EDGE STAINLESS'){
                        NewValueToAssign = {'value':'STAINLESS'};
                    }else if(fieldApiName == 'Color_2__c' && pdcType == 'CUSTOM GALVANIZED CLEAT'){
                        NewValueToAssign = {'value':'GALVANIZED CLEAT'};
                    }else if(fieldApiName == 'Color_2__c' && pdcType == 'CUSTOM STAINLESS CLEAT'){
                        NewValueToAssign = {'value':'STAINLESS CLEAT'};
                    }
                }
                NewValueToAssign['idsToMap'] = idsToMap;
                if(/Price/i.test(fieldApiName)){
                    NewValueToAssign['type'] = 'number';
                    NewValueToAssign['formatter'] = 'currency';
                    NewValueToAssign['step'] = '0.01';
                }else{
                    NewValueToAssign['type'] = 'text';
                    NewValueToAssign['formatter'] = '';
                    NewValueToAssign['step'] = '';
                }
                Object.getOwnPropertyNames(fieldsList[fKey]).forEach((item,index)=>{
                    NewValueToAssign[item] = fieldsList[fKey][item];
                });
                tempProductToShowList.push(NewValueToAssign);
            }
            console.log('tempProductToShowList %% ', tempProductToShowList);
            //productToShowList.push(tempProductToShowList);
            var standPdc = [];
            var cusPdc = [];
            for(let key in tempProductToShowList){
                if(tempProductToShowList[key]['Field_API_Name__c'].includes('Product2.')){
                    standPdc.push(tempProductToShowList[key]);
                }else{
                    cusPdc.push(tempProductToShowList[key]);
                }
            }
            var pdcToShowObj = {}
            pdcToShowObj = Object.assign({}, {'standPdc':standPdc});
            pdcToShowObj['cusPdc'] = cusPdc;
            productToShowList.push(pdcToShowObj);
        }
        console.log('productToShowList ## ', productToShowList);
            if(component.get('v.customTableColumns') === undefined){
                if(Number(productToShowList[0]['standPdc'].length) <= 12){
                	let columns = parseInt(12/(parseInt(Number(productToShowList[0]['standPdc'].length)/2,10)), 10);
                    console.log('columns $$ ', columns);
                    component.set('v.customTableColumns', columns);
                }else if(Number(productToShowList[0]['standPdc'].length) > 12){
                    component.set('v.customTableColumns', 2);
                }
            }
        component.set('v.customProductList', productToShowList);
    },
    
    distributeData : function(component, result){
        component.set('v.productColorList', []);
        component.set('v.productNameList', []);
        component.set('v.productSizeList', []);
        component.set('v.productThicknessList', []);
        component.find('productName').set("v.value", '');
        component.find('productColor').set("v.value", '');
        component.find('productSize').set("v.value", '');
        component.find('productThickness').set("v.value", '');
        var pdcRecords = JSON.parse(JSON.stringify(result));
        var pdcNameList = [];
        var pdcNameOptionsList = [];
        var colorList = [];
        var colorOptionsList = [];
        var pdcSizeList = [];
        var pdcSizeOptionsList = [];
        var pdcThicknessList = [];
        var pdcThicknessOptionsList = [];
        pdcNameOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
        colorOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
        pdcSizeOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
        pdcThicknessOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
        pdcRecords.forEach((e, i)=>{
            if(e.Product2.hasOwnProperty('Color_2__c') && !colorList.includes(e.Product2.Color_2__c)){
            	colorList.push(e.Product2.Color_2__c);
                let colorOption = Object.assign({}, {label:e.Product2.Color_2__c, value:e.Product2.Color_2__c});
        		colorOptionsList.push(colorOption);
        	}
    		if(e.Product2.hasOwnProperty('Name') && !pdcNameList.includes(e.Product2.Name)){
            	pdcNameList.push(e.Product2.Name);
                let pdcNameOption = Object.assign({}, {label:e.Product2.Name, value:e.Product2.Name});
        		pdcNameOptionsList.push(pdcNameOption);
        	}
            if(e.Product2.hasOwnProperty('Product_Size_2__c') && !pdcSizeList.includes(e.Product2.Product_Size_2__c)){
            	pdcSizeList.push(e.Product2.Product_Size_2__c);
                let pdcSizeOption = Object.assign({}, {label:e.Product2.Product_Size_2__c, value:e.Product2.Product_Size_2__c});
        		pdcSizeOptionsList.push(pdcSizeOption);
        	}
    		if(e.Product2.hasOwnProperty('Thickness_2__c') && !pdcThicknessList.includes(e.Product2.Thickness_2__c)){
            	pdcThicknessList.push(e.Product2.Thickness_2__c);
                let pdcThicknessOption = Object.assign({}, {label:e.Product2.Thickness_2__c, value:e.Product2.Thickness_2__c});
        		pdcThicknessOptionsList.push(pdcThicknessOption);
        	}
        });
			console.log('pdcThicknessOption :: ', pdcThicknessOptionsList);
			pdcNameOptionsList.sort( this.sortArray );
            if(colorOptionsList.length>0){
                colorOptionsList.sort( this.sortArray );
                colorOptionsList = this.numericSort(colorOptionsList);
                component.set('v.productColorList', colorOptionsList);
            }
            if(pdcNameOptionsList.length>0){
                pdcNameOptionsList.sort( this.sortArray );
                pdcNameOptionsList = this.numericSort(pdcNameOptionsList);
                component.set('v.productNameList', pdcNameOptionsList);
            }
            if(pdcSizeOptionsList.length>0){
                pdcSizeOptionsList.sort( this.sortArray );
                pdcSizeOptionsList = this.numericSort(pdcSizeOptionsList);
                component.set('v.productSizeList', pdcSizeOptionsList);
            }
			if(pdcThicknessOptionsList.length>0){
                pdcThicknessOptionsList.sort( this.sortArray );
                pdcThicknessOptionsList = this.numericSort(pdcThicknessOptionsList);
                component.set('v.productThicknessList', pdcThicknessOptionsList);
            }
    	},
        
        reAssignOptions : function(component, result){
            var pdcRecords = JSON.parse(JSON.stringify(result));
            var pdcNameList = [];
            var pdcNameOptionsList = [];
            var colorList = [];
            var colorOptionsList = [];
            var pdcSizeList = [];
            var pdcSizeOptionsList = [];
            var pdcThicknessList = [];
        	var pdcThicknessOptionsList = [];
            pdcNameOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
        	colorOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
        	pdcSizeOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
            pdcThicknessOptionsList.push(Object.assign({}, {label:'--Select--', value:''}));
            pdcRecords.forEach((e, i)=>{
                if(e.Product2.hasOwnProperty('Color_2__c') && !colorList.includes(e.Product2.Color_2__c)){
                    colorList.push(e.Product2.Color_2__c);
                    let colorOption = Object.assign({}, {label:e.Product2.Color_2__c, value:e.Product2.Color_2__c});
                    colorOptionsList.push(colorOption);
                }
                if(e.Product2.hasOwnProperty('Name') && !pdcNameList.includes(e.Product2.Name)){
                    pdcNameList.push(e.Product2.Name);
                    let pdcNameOption = Object.assign({}, {label:e.Product2.Name, value:e.Product2.Name});
                    pdcNameOptionsList.push(pdcNameOption);
                }
                if(e.Product2.hasOwnProperty('Product_Size_2__c') && !pdcSizeList.includes(e.Product2.Product_Size_2__c)){
                    pdcSizeList.push(e.Product2.Product_Size_2__c);
                    let pdcSizeOption = Object.assign({}, {label:e.Product2.Product_Size_2__c, value:e.Product2.Product_Size_2__c});
                    pdcSizeOptionsList.push(pdcSizeOption);
                }
				if(e.Product2.hasOwnProperty('Thickness_2__c') && !pdcThicknessList.includes(e.Product2.Thickness_2__c)){
                    pdcThicknessList.push(e.Product2.Thickness_2__c);
                    let pdcThicknessOption = Object.assign({}, {label:e.Product2.Thickness_2__c, value:e.Product2.Thickness_2__c});
                    pdcThicknessOptionsList.push(pdcThicknessOption);
                }
            });
			console.log('pdcThicknessOption :: ', pdcThicknessOptionsList);
            /*if(colorOptionsList.length>0){
                component.set('v.productColorList', colorOptionsList);
            }
            if(pdcNameOptionsList.length>0){
                component.set('v.productNameList', pdcNameOptionsList);
            }
            if(pdcSizeOptionsList.length>0){
                component.set('v.productSizeList', pdcSizeOptionsList);
            }
			if(pdcThicknessOptionsList.length>0){
                component.set('v.productThicknessList', pdcThicknessOptionsList);
            }*/
			pdcNameOptionsList.sort( this.sortArray );
            if(colorOptionsList.length>0){
                colorOptionsList.sort( this.sortArray );
                colorOptionsList = this.numericSort(colorOptionsList);
                component.set('v.productColorList', colorOptionsList);
            }
            if(pdcNameOptionsList.length>0){
                pdcNameOptionsList.sort( this.sortArray );
                pdcNameOptionsList = this.numericSort(pdcNameOptionsList);
                component.set('v.productNameList', pdcNameOptionsList);
            }
            if(pdcSizeOptionsList.length>0){
                pdcSizeOptionsList.sort( this.sortArray );
                pdcSizeOptionsList = this.numericSort(pdcSizeOptionsList);
                component.set('v.productSizeList', pdcSizeOptionsList);
            }
			if(pdcThicknessOptionsList.length>0){
                pdcThicknessOptionsList.sort( this.sortArray );
                pdcThicknessOptionsList = this.numericSort(pdcThicknessOptionsList);
                component.set('v.productThicknessList', pdcThicknessOptionsList);
            }
        },
        sortArray : function(val1, val2){
            if ( val1.label < val2.label ){
                return -1;
            }
            if ( val1.label > val2.label ){
                return 1;
            }
            return 0;
        },
        
            numericSort : function(propertyList){
                let propertyMap = new Map();
                propertyList.forEach((items) =>{
                    let item = items.value;
                    if(item.length > 0 && !isNaN(item[0])){
                    	let len = item.length;
                    	//console.log('item :: ', item);
                        for(let i = 0; i < (len - 1); i++){
                    		if(!isNaN(item[i]) == false){
                    			let newstr = item.slice(0, i);
                    			//console.log('newstr :: ', newstr);
                    			let num = parseInt(newstr, 10);
                    			propertyMap.set(item, num);
                    			len = 0;
                			}
                        }
                     }else{
                         propertyMap.set(item, item);       
                      }
                });
                //console.log('size :: ', propertyMap.size);
                const sortPropertyMap = new Map([...propertyMap.entries()].sort((a, b) => a[1] - b[1]));
				let results = [];
                sortPropertyMap.forEach((value, key)=>{
                    let result = Object.assign({}, {label:key, value:key});
					results.push(result);
                    //console.log(value,  ' ', key);
                });
                return results;
            }
	
})