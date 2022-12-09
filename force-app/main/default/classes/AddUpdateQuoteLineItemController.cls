public class AddUpdateQuoteLineItemController {
    @AuraEnabled
    public static Map<String, Object> getProductType(Id quoteId){
        System.debug('recordId :: ' + quoteId);
        Map<String, Object> r = new Map<String, Object>();
        try{
            List<QuoteLineItem> quoteLineItem = [SELECT Id, Product2.ProductCode,
                                                 Product2.name,Product2.Weight__c,
                                                 Product2.Color_2__c, Product2.Product_Size_2__c,
                                                 Product2.Package_2__c, Description,
                                                 Quantity, UnitPrice,OpportunityLineItemId
                                                 FROM QuoteLineItem
                                                 WHERE QuoteId=:quoteId];
            if(quoteLineItem.size() > 0){
                System.debug('quoteLineItem :: ' + quoteLineItem);
                r.put('quoteLineItem', quoteLineItem);
            }
            
            Set<String> pFamily = new Set<String>();
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            pbeList = [SELECT Id, Pricebook2Id, 
                       Product2Id, Product2.ProductCode, 
                       Product2.Name, Product2.Color_2__c,
                       Product2.Product_Size_2__c, Product2.Weight__c,
                       Product2.Family, Product2.StockKeepingUnit,
                       Product2.Thickness_2__c,Product2.Weight_lbs_2__c,
                       Product2.Package_2__c,Product2.Coverage__c,
                       UnitPrice
                       FROM PricebookEntry 
                       WHERE Product2.CommercientSF8__SAGE100_CI_ITEM__r.CommercientSF8__ProductLine__c !='ZZZZ' 
                       AND Product2.CommercientSF__ExternalKey__c != NULL 
                       AND Pricebook2.IsStandard = true  
                       AND IsActive=true ORDER BY Product2.Family ASC];
            
            List<Quote> quote = [SELECT Id, name, OpportunityId, AccountId FROM Quote WHERE id=:quoteId];
            List<Opportunity> opp = [SELECT Id, Pricebook2Id  FROM Opportunity WHERE id=:quote[0].OpportunityId];
            List<Account> acc = new List<Account>();
            if(String.isNotBlank(quote[0].OpportunityId)){
                r.put('opptyId', quote[0].OpportunityId);
            }
            if(String.isNotBlank(opp[0].Pricebook2Id)){
                r.put('priceBookId', opp[0].Pricebook2Id);
            }
               
            if(String.isNotBlank(quote[0].AccountId)){
                acc = [SELECT name FROM Account WHERE id=:quote[0].AccountId];
                if(acc.size()>0){
                	r.put('accountName', acc[0].Name);
                }
                //r.put('opptyId', quote[0].OpportunityId);
                //System.debug('pricebookentryId :: ' + opp[0].Pricebook2Id);
                //r.put('priceBookId', opp[0].Pricebook2Id);
            }
            /*if(acc.size()>0){
                r.put('accountName', acc[0].Name);
            }*/
            if(pbeList.size() > 0){
                for(PricebookEntry p : pbeList){
                    if(!pFamily.contains(p.Product2.Family) && p.Product2.Family!= null){
                        pFamily.add(p.Product2.Family);
                    }
                }
                if(pFamily.size()>0){
                    System.debug('pFamily.length() $$ ' + pFamily.size());
                    r.put('pfamily', pFamily);
                }
            }else{
                r.put('error', 'No Product Found.');
            }
        }catch(Exception e){
            System.debug('Server Side Error ##... ' + e.getMessage());
            r.put('error', 'Server Side Error ##...' + e.getMessage());
            //throw new AuraHandledException(e.getMessage());
        }
        System.debug('r :: ' + r);
        return r;
    }
    
    @AuraEnabled
    public static Map<String, Object> getProductByType(String productType){
        Map<String, Object> r = new Map<String, Object>();
        System.debug('productType ##... ' + productType);
            List<PricebookEntry> pbeList = [SELECT Id, Pricebook2Id, 
                                            Product2Id, Product2.ProductCode, 
                                            Product2.Name, Product2.Color_2__c,
                                            Product2.Product_Size_2__c, Product2.Weight__c,
                                            Product2.Family, Product2.StockKeepingUnit,
                                            Product2.Thickness_2__c,Product2.Weight_lbs_2__c,
                                            Product2.Package_2__c,Product2.Coverage__c,
                                            UnitPrice 
                                            FROM PricebookEntry 
                                            WHERE Product2.CommercientSF8__SAGE100_CI_ITEM__r.CommercientSF8__ProductLine__c !='ZZZZ' AND Product2.CommercientSF__ExternalKey__c != NULL AND Pricebook2.IsStandard = true AND
                                            IsActive=true AND
                                            Product2.Family=:productType];
            System.debug('record...' + pbeList);
            if(pbeList.size()>0){
                r.put('result', pbeList);
            }else{
                r.put('error', 'No Product Found with \'' + productType + '\' product family');
            }
        
        return r;
    }    
    
    @AuraEnabled
    public static Map<String, Object> getProductBySearchTerm(String searchStr){
        Map<String, Object> r = new Map<String, Object>();
        try{
            SearchData s = new SearchData();
            s = (SearchData)JSON.deserialize(searchStr, SearchData.class);
            String soql = 'SELECT Id, Pricebook2Id, Product2Id, Product2.Family, Product2.Name, Product2.ProductCode, Product2.Bulk_Box_Price__c, UnitPrice, Product2.Color_2__c, Product2.Product_Size_2__c, Product2.Thickness_2__c, Product2.Coverage__c, Product2.Weight__c, Product2.Package_2__c, Product2.StockKeepingUnit FROM PricebookEntry WHERE Product2.CommercientSF8__SAGE100_CI_ITEM__r.CommercientSF8__ProductLine__c !=\'ZZZZ\'AND Product2.CommercientSF__ExternalKey__c != NULL AND Pricebook2.IsStandard = true  AND IsActive=true';
            System.debug(s.searchStr);
            System.debug(s.pdcType);
            System.debug(s.pdcName);
            System.debug(s.pdcColor);
            System.debug(s.pdcSize);
            if (String.isBlank(s.searchStr) == false) {
                String skuContains = '%' + s.searchStr +'%';
                soql += ' AND Product2.ProductCode LIKE :skuContains';
            } 
            
            if (String.isBlank(s.pdcType) == false) {
                String type = s.pdcType;
                soql += ' AND Product2.Family = :type';
            }
            
            if (String.isBlank(s.pdcName) == false) {
                String name = '%' + s.pdcName +'%';
                System.debug('name :: ' + name);
                soql += ' AND Product2.Name Like :name';
            }
            
            if (String.isBlank(s.pdcColor) == false) {
                String color = s.pdcColor;
                soql += ' AND Product2.Color_2__c = :color';
            }
            
            if (String.isBlank(s.pdcSize) == false) {
                String size = s.pdcSize;
                soql += ' AND Product2.Product_Size_2__c LIKE :size';
            }
            
            system.debug(soql);
            List<PricebookEntry> searchedProductList = (List<PricebookEntry>) Database.query(soql);
            System.debug('searchStr ## ' + searchedProductList);
            if(searchedProductList.size()>0){
                r.put('result', searchedProductList);
            }else {
                r.put('error', 'No Product Found');
            }
        }catch(Exception e){
            System.debug('Server Side Error ##... ' + e.getMessage());
            r.put('error', 'Server Side Error ##...' + e.getMessage());
        }
        return r;
    }
    
    @AuraEnabled
    public static Map<String, Object> addQuoteLineItem(String recordDetails, String findProductData){
        //String recordDetails = recordDetailsString;
        Map<String, Object> r = new Map<String, Object>();
        System.debug('recordDetails :: ' + recordDetails);
        System.debug('findProductData :: ' + findProductData);
        System.debug('recordDetails :: ' + JSON.deserializeStrict(recordDetails, QuoteLineItem.Class)); 
        OpportunityLineItem opptylineItem ; 
        if(String.isNotBlank(findProductData)){
        	System.debug('recordDetails_OpportunityLineItem :: ' + JSON.deserializeStrict(findProductData, OpportunityLineItem.Class)); 
            opptylineItem = (OpportunityLineItem)JSON.deserializeStrict(findProductData, OpportunityLineItem.Class);
        }
        QuoteLineItem qli = (QuoteLineItem)JSON.deserializeStrict(recordDetails, QuoteLineItem.Class);
        
        OpportunityLineItem oli = new OpportunityLineItem(Product2Id = qli.Product2Id,
                                                          OpportunityId = qli.OpportunityLineItemId,
                                                          Quantity = qli.Quantity, 
                                                          PricebookEntryId = (Id)qli.PricebookEntryId, 
                                                          UnitPrice = qli.UnitPrice, 
                                                          Description = qli.Description); 
        insert oli;
        if(String.isNotEmpty(findProductData)){
        	opptylineItem.id = oli.Id;
            update opptylineItem;
        }
        if(String.isNotBlank(qli.Product2Id)){
            qli.OpportunityLineItemId = oli.id;
            insert qli;
            /*ql = new QuoteLineItem (Product2Id = qli.Product2Id,
                                                  QuoteId = qli.QuoteId,
                                                  Quantity = qli.Quantity, 
                                                  PricebookEntryId = (Id)qli.PricebookEntryId, 
                                                  UnitPrice = qli.UnitPrice, 
                                                  Description = qli.Description,
                                                  OpportunityLineItemId = oli.id
                                                 );
            insert ql;*/
        }
        List<QuoteLineItem> quoteLineItem = [SELECT Id, Product2.ProductCode,
                                             Product2.name,Product2.Weight__c,
                                             Product2.Color_2__c,
                                             Product_Color__c, Product2.Product_Size_2__c,
                                             Product2.Package_2__c, Description,
                                             Quantity, UnitPrice
                                             FROM QuoteLineItem
                                             WHERE Id=:qli.Id];
        
        if(quoteLineItem.size()>0){
            r.put('newQuoteLineItem', quoteLineItem[0]);
        }
        return r;
    }
    
    @AuraEnabled
    public static Map<String, Object> deleteQuoteLineItem(Id recordId, Id quoteId){
        Map<String, Object> r = new Map<String, Object>();
        
        List<QuoteLineItem> quoteLineItem = [SELECT Id, Product2.ProductCode,
                                             Product2.name,Product2.Weight__c,Product2.Color_2__c,
                                             Product_Color__c, Product2.Product_Size_2__c,
                                             Product2.Package_2__c, Description,
                                             Quantity, UnitPrice, OpportunityLineItemId
                                             FROM QuoteLineItem
                                             WHERE Id=:recordId AND QuoteId=:quoteId LIMIT 1];
        if(quoteLineItem.size()>0){
            OpportunityLineItem oli = new OpportunityLineItem(id=quoteLineItem[0].OpportunityLineItemId);
            delete oli;
            delete quoteLineItem[0];
            r.put('result', 'Quote Line Item Deleted.');
        }else{
            r.put('error', 'No Quote Line Item to Delete.');
        }
        return r;
    }
    
    @AuraEnabled
    public static Map<String, Object> updateQuoteLineItem(String qliToUpdate, Id quoteId){
        System.debug('qliToUpdate :: ' + qliToUpdate);
        Map<String, Object> r = new Map<String, Object>();
        UpdateQliWrapper qliwrapper = new UpdateQliWrapper();
        qliwrapper = (UpdateQliWrapper)JSON.deserialize(qliToUpdate, UpdateQliWrapper.class);
        QuoteLineItem qli = new QuoteLineItem(id = qliwrapper.Id,
                                              Description = qliwrapper.specialNotes,
                                              Quantity = qliwrapper.quantity,
                                              QuoteId = quoteId,
                                              UnitPrice = qliwrapper.unitprice);
        update qli;
        
        List<QuoteLineItem> quoteLineItem = [SELECT Id, OpportunityLineItemId
                                             FROM QuoteLineItem
                                             WHERE Id=:qli.Id AND QuoteId=:quoteId LIMIT 1];
        System.debug('quoteLineItem :: ' + quoteLineItem);
        List<OpportunityLineItem> oli = new List<OpportunityLineItem>();
        if(quoteLineItem.size()>0){
            oli = [SELECT Id
                   FROM OpportunityLineItem
                   WHERE Id=:quoteLineItem[0].OpportunityLineItemId LIMIT 1];
            System.debug('oli :: ' + oli);
        }
        if(oli.size()>0){
            OpportunityLineItem oliToUpdate = new OpportunityLineItem(id = oli[0].Id,
                                                                      Description = qli.Description,
                                                                      Quantity = qli.Quantity,
                                                                      UnitPrice = qli.UnitPrice);
            update oliToUpdate;
            System.debug('oliToUpdate :: ' + oliToUpdate);
        }
        r.put('success','Record has been updated.');
        return r;
    }
    
    
    @AuraEnabled
    public static Map<String, Object> getCustomFindProductFields(String customProductType){
        System.debug('customProductType :: ' + customProductType);
        Map<String, Object> r = new Map<String, Object>();
        List<Custom_Product_Type__c> cptList = [SELECT id, name,
                                                Columns__c, Diagram__c,
                                                Object_API_Name__c,
                                                Product_Selection_Where__c,
                                                Pricing_Calculation__c,
                                                Product_Type__c,
                                                View_Type__c
                                                FROM Custom_Product_Type__c
                                                WHERE Product_Type__c =: customProductType AND
                                                View_Type__c = 'Find Product'  LIMIT 1];
        List<Custom_Product_Fields__c> cpfList = new List<Custom_Product_Fields__c>();
        if(cptList.size()>0){
            cpfList = [SELECT id, Name,
                       Field_API_Name__c,
                       Order__c, Read_Only__c,
                       Required__c, Custom_Product_Type__c,
                       Picklist_Values__c, Split__c,
                       View_Product_Display_Order__c,
                       Find_Product_Display_Order__c,
                       Add_Product_Display_Order__c
                       FROM Custom_Product_Fields__c
                       WHERE Custom_Product_Type__c =:cptList[0].id
                       ORDER BY Order__c ASC];
        }
        if(cpfList.size()>0){
            r.put('customFindProductFields', cpfList);
            r.put('customFindProductType', cptList[0]);
        }else{
            r.put('error', 'No Data For Custom Product Type');
        }
        return r;
    }
    
    @AuraEnabled
    public static Map<String, Object> getCustomAddProductFields(Id quoteId, String customProductType, String findPdcVal){
        Map<String, Object> r = new Map<String, Object>();
        QuoteLineItem pdcSelectionObj = new QuoteLineItem();
        System.debug('pdcSelectionObj :: ' + pdcSelectionObj);
        Decimal updatedUnitPrice = 0.0;
        if(findPdcVal.length()>0){
            pdcSelectionObj = (QuoteLineItem)JSON.deserializeStrict(findPdcVal, QuoteLineItem.class);
            Boolean isUnitPriceCalculatable = true;
            if(customProductType != 'CUSTOM DECKSHIELD BY THE LINEAL FOOT'){
                if(customProductType == 'CUSTOM DRIP EDGE WHITE' || customProductType == 'CUSTOM DRIP EDGE COLORS' || customProductType == 'CUSTOM DRIP EDGE STAINLESS'){
                    if((pdcSelectionObj.GS_length_W1__c == null || pdcSelectionObj.GS_length_W1__c < 0.0)){
                        isUnitPriceCalculatable = false;
                    }
                }
                if((pdcSelectionObj.Return_on_Deck__c == null || pdcSelectionObj.Return_on_Deck__c <= 0.0)){
                    isUnitPriceCalculatable = false;
                }
                if((pdcSelectionObj.of_Bends__c == null || pdcSelectionObj.of_Bends__c <= 0.0)){
                    isUnitPriceCalculatable = false;
                }
                if((pdcSelectionObj.Height_H__c == null ||pdcSelectionObj.Height_H__c <= 0)){
                    isUnitPriceCalculatable = false;
                }
            }
            if(customProductType == 'CUSTOM DECKSHIELD BY THE LINEAL FOOT'){
                if((pdcSelectionObj.Length_Requested__c == null ||pdcSelectionObj.Length_Requested__c <= 0) && (pdcSelectionObj.Cost_Per_Lineal_Foot__c == null ||pdcSelectionObj.Cost_Per_Lineal_Foot__c <= 0)){
                    isUnitPriceCalculatable = false;
                }
            }
            
            if(isUnitPriceCalculatable){
                SetUnitPrice sup = new SetUnitPrice();
                updatedUnitPrice = sup.setUnitPrice(customProductType, pdcSelectionObj);
                System.debug('updatedUnitPrice $$ ' + updatedUnitPrice);
            }
            System.debug('pdcSelectionObj $$ ' + pdcSelectionObj);
        }
        List<Custom_Product_Type__c> cptList = [SELECT id, name,
                                                Columns__c, Diagram__c,
                                                Object_API_Name__c,
                                                Product_Selection_Where__c,
                                                Pricing_Calculation__c,
                                                Product_Type__c,
                                                View_Type__c
                                                FROM Custom_Product_Type__c
                                                WHERE Product_Type__c =: customProductType AND
                                                View_Type__c = 'Add Product'  LIMIT 1];
        List<Custom_Product_Fields__c> cpfList = new List<Custom_Product_Fields__c>();
        if(cptList.size()>0){
            cpfList = [SELECT id, Name,
                       Field_API_Name__c,
                       Order__c, Read_Only__c,
                       Required__c, Custom_Product_Type__c,
                       Picklist_Values__c, Split__c,
                       View_Product_Display_Order__c,
                       Find_Product_Display_Order__c,
                       Add_Product_Display_Order__c
                       FROM Custom_Product_Fields__c
                       WHERE Custom_Product_Type__c =:cptList[0].id
                       ORDER BY Order__c ASC];
        }
        String query = 'SELECT Id, Pricebook2Id, Product2Id';
        Set<String> priceBookEntryFields = Schema.SObjectType.PricebookEntry.fields.getMap().keySet();
        for(Custom_Product_Fields__c cpf : cpfList){
            if(priceBookEntryFields.contains(cpf.Field_API_Name__c.toLowercase()) || cpf.Field_API_Name__c.contains('Product2.')) {
                query += ', ' + cpf.Field_API_Name__c;
            }
        }
        query += ' FROM PricebookEntry WHERE Product2.CommercientSF8__SAGE100_CI_ITEM__r.CommercientSF8__ProductLine__c !=\'ZZZZ\' AND Product2.CommercientSF__ExternalKey__c!=NULL AND Pricebook2.IsStandard = true  AND IsActive=true AND Product2.Family=\''+customProductType+'\'';
        
        SetProductSelectionQuery setQuery = new SetProductSelectionQuery();
        List<PricebookEntry> pdeList = setQuery.getPriceBookEntryList(customProductType, pdcSelectionObj, query);
        
        List<SearchResult> searchResultList = new List<SearchResult>();
        for(PricebookEntry p : pdeList){
            if(customProductType == 'CUSTOM DRIP EDGE WHITE' || customProductType == 'CUSTOM DRIP EDGE COLORS' || customProductType == 'CUSTOM DRIP EDGE STAINLESS' || customProductType == 'CUSTOM GALVANIZED CLEAT' || customProductType == 'CUSTOM STAINLESS CLEAT' || customProductType == 'CUSTOM DECKSHIELD BY THE LINEAL FOOT'){
                if(updatedUnitPrice >= 0.00){
                    p.UnitPrice = updatedUnitPrice;
                    //p.ListPrice = updatedUnitPrice;
                }
            }
            SearchResult sr = new SearchResult();
            sr.pbe = p;
            //sr.qli = new QuoteLineItem(UnitPrice=p.UnitPrice);
           	sr.qli = new QuoteLineItem(Product2Id = p.Product2Id, QuoteId = quoteId, PricebookEntryId=p.Id, UnitPrice=p.UnitPrice);
            searchResultList.add(sr);
        }
        System.debug('searchResultList :: ' + searchResultList);
        if(cpfList.size()>0 && searchResultList.size() > 0){
            r.put('customAddProductFields', cpfList);
            r.put('customAddProductType', cptList[0]);
            r.put('customProductList', pdeList);
            r.put('searchResult', searchResultList);
        }else{
            r.put('error', 'No Data For Custom Product Type');
        }
        return r;
    }
    
    public class SearchResult{
        @AuraEnabled
        public PricebookEntry pbe{get;set;}
        //@AuraEnabled
        //public Product2 product{get;set;}
        @AuraEnabled
        public QuoteLineItem qli{get;set;}
    }
    
    public class SearchData{
        @AuraEnabled
        public String pdcName{get;set;}
        @AuraEnabled
        public String pdcColor{get;set;}
        @AuraEnabled
        public String pdcType{get;set;}
        @AuraEnabled
        public String searchStr{get;set;}
        @AuraEnabled
        public String pdcSize{get;set;}
        
    }
    
    public class UpdateQliWrapper{
        @AuraEnabled
        public Id Id{get;set;}
        @AuraEnabled
        public String specialNotes{get;set;}
        @AuraEnabled
        public Decimal unitprice{get;set;}
        @AuraEnabled
        public Integer quantity{get;set;}
    } 
    
    public class SetProductSelectionQuery{        
        public List<PricebookEntry> getPriceBookEntryList(String customProductType, QuoteLineItem pdcSelectionObj, String query){
            List<PricebookEntry> pdeList = new List<PricebookEntry>();
            if(customProductType == 'CUSTOM CONE'){
                System.debug('Product_Color__c $$ ' + pdcSelectionObj.Product_Color__c);
                if(pdcSelectionObj.Product_Color__c != NULL &&  pdcSelectionObj.Product_Color__c != ''){
                    //query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Product_Color__c + '\'';
                }
                if(!(pdcSelectionObj.Bottom_Diameter_BD__c < 0) && !(pdcSelectionObj.Height_H__c < 0) && pdcSelectionObj.Bottom_Diameter_BD__c != null && pdcSelectionObj.Height_H__c != null){
                    Decimal val = pdcSelectionObj.Bottom_Diameter_BD__c + pdcSelectionObj.Height_H__c;
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }else if (!(pdcSelectionObj.Bottom_Diameter_BD__c < 0) && pdcSelectionObj.Bottom_Diameter_BD__c != null){
                    Decimal val = pdcSelectionObj.Bottom_Diameter_BD__c;
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }else if(!(pdcSelectionObj.Height_H__c < 0) && pdcSelectionObj.Height_H__c != null){
                    Decimal val = pdcSelectionObj.Height_H__c;
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
            }else if(customProductType == 'CUSTOM PITCH PAN'){
                System.debug('customProductType :: ' + customProductType);
                Decimal val = 0.00;
                if(pdcSelectionObj.Width_Upper__c != NULL &&  !(pdcSelectionObj.Width_Upper__c < 0)){
                    val +=  pdcSelectionObj.Width_Upper__c;
                }
                if(pdcSelectionObj.Length_Upper__c != NULL &&  !(pdcSelectionObj.Length_Upper__c < 0)) {
                    val += pdcSelectionObj.Length_Upper__c;
                }
                if(pdcSelectionObj.Height_H__c != NULL &&  !(pdcSelectionObj.Height_H__c < 0)) {
                    val += pdcSelectionObj.Height_H__c;
                }
                System.debug('val :: ' + val);
                if(val >= 0.00 && pdcSelectionObj.Width_Upper__c != NULL && pdcSelectionObj.Length_Upper__c != NULL &&  pdcSelectionObj.Height_H__c != NULL){
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
            }else if(customProductType == 'CUSTOM POST FLASHING'){
                System.debug('customProductType :: ' + customProductType);
                Decimal val = 0.00;
                if(pdcSelectionObj.Product_Color__c != NULL &&  pdcSelectionObj.Product_Color__c != ''){
                    //query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Product_Color__c + '\'';
                }
                if(pdcSelectionObj.Width_Upper__c != NULL &&  !(pdcSelectionObj.Width_Upper__c < 0)){
                    val +=  pdcSelectionObj.Width_Upper__c;
                }
                if(pdcSelectionObj.Length_Upper__c != NULL &&  !(pdcSelectionObj.Length_Upper__c < 0)) {
                    val += pdcSelectionObj.Length_Upper__c;
                }
                if(pdcSelectionObj.Height_H__c != NULL &&  !(pdcSelectionObj.Height_H__c < 0)) {
                    val += pdcSelectionObj.Height_H__c;
                }
                System.debug('val :: ' + val);
                if(val >= 0.00 && pdcSelectionObj.Width_Upper__c != NULL && pdcSelectionObj.Length_Upper__c != NULL &&  pdcSelectionObj.Height_H__c != NULL){
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM THROUGHWALL SCUPPER'){
                System.debug('customProductType :: ' + customProductType);
                if(pdcSelectionObj.Color_Metal__c != NULL &&  pdcSelectionObj.Color_Metal__c != ''){
                    //query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Color_Metal__c + '\'';
                }
                Decimal val = 0.00;
                if(pdcSelectionObj.Width__c != NULL &&  !(pdcSelectionObj.Width__c < 0)){
                    val +=  pdcSelectionObj.Width__c;
                }
                if(pdcSelectionObj.Length__c != NULL &&  !(pdcSelectionObj.Length__c < 0)) {
                    val += pdcSelectionObj.Length__c;
                }
                if(pdcSelectionObj.Height_H__c != NULL &&  !(pdcSelectionObj.Height_H__c < 0)) {
                    val += pdcSelectionObj.Height_H__c;
                }
                System.debug('val :: ' + val);
                if(val >= 0.00 && pdcSelectionObj.Width__c != NULL && pdcSelectionObj.Length__c != NULL &&  pdcSelectionObj.Height_H__c != NULL){
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM OVERFLOW SCUPPER'){
                System.debug('customProductType :: ' + customProductType);
                System.debug('pdcSelectionObj :: ' + pdcSelectionObj);
                Decimal val = 0.00;
                if(pdcSelectionObj.Color_Metal__c != NULL &&  pdcSelectionObj.Color_Metal__c != ''){
                    //query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Color_Metal__c + '\'';
                }
                if(pdcSelectionObj.Width__c != NULL &&  !(pdcSelectionObj.Width__c < 0)){
                    val +=  pdcSelectionObj.Width__c;
                }
                if(pdcSelectionObj.Length__c != NULL &&  !(pdcSelectionObj.Length__c < 0)) {
                    val += pdcSelectionObj.Length__c;
                }
                if(pdcSelectionObj.Height_H__c != NULL &&  !(pdcSelectionObj.Height_H__c < 0)) {
                    val += pdcSelectionObj.Height_H__c;
                }
                System.debug('val :: ' + val);
                if(val >= 0.00 && pdcSelectionObj.Width__c != NULL && pdcSelectionObj.Length__c != NULL &&  pdcSelectionObj.Height_H__c != NULL){
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM DRIP EDGE WHITE'){
                System.debug('customProductType :: ' + customProductType);
                query += ' AND Product2.ProductCode =' + '\'' + 'C-MW' + '\'';
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM DRIP EDGE COLORS'){
                System.debug('customProductType :: ' + customProductType);
                if(pdcSelectionObj.Product_Color__c != NULL &&  pdcSelectionObj.Product_Color__c != ''){
                    //query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Product_Color__c + '\'';
                }
                query += ' AND Product2.ProductCode =' + '\'' + 'C-MC' + '\'';
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM DRIP EDGE STAINLESS'){
                System.debug('customProductType :: ' + customProductType);
                query += ' AND Product2.ProductCode =' + '\'' + 'C-MSS' + '\'';
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM GALVANIZED CLEAT'){
                System.debug('customProductType :: ' + customProductType);
                query += ' AND Product2.ProductCode =' + '\'' + 'C-GALVCLEAT' + '\'';
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM STAINLESS CLEAT'){
                System.debug('customProductType :: ' + customProductType);
                query += ' AND Product2.ProductCode =' + '\'' + 'C-SSCLEAT' + '\'';
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM DRAIN LINER'){
                System.debug('customProductType :: ' + customProductType);
                Decimal val = 0.00;
                if(pdcSelectionObj.Product_Color__c != NULL &&  pdcSelectionObj.Product_Color__c != ''){
                    //query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Product_Color__c + '\'';
                }
                if(pdcSelectionObj.Drain_Diameter__c != NULL &&  !(pdcSelectionObj.Drain_Diameter__c < 0)){
                    val +=  pdcSelectionObj.Drain_Diameter__c;
                }
                if(pdcSelectionObj.Height_H__c != NULL &&  !(pdcSelectionObj.Height_H__c < 0)) {
                    val += pdcSelectionObj.Height_H__c;
                }
                if(val >= 0.00 && pdcSelectionObj.Drain_Diameter__c != NULL && pdcSelectionObj.Height_H__c != NULL){
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM CLAD METAL DROP SCUPPER ROUND'){
                System.debug('customProductType :: ' + customProductType);
                Decimal val = 0.00;
                if(pdcSelectionObj.Drain_Diameter__c != NULL &&  !(pdcSelectionObj.Drain_Diameter__c < 0)){
                    val +=  pdcSelectionObj.Drain_Diameter__c;
                }
                if(pdcSelectionObj.Drain_Diameter__c >0 && pdcSelectionObj.Drain_Diameter__c <=4){
                    query += ' AND Product2.ProductCode=\'C-CDSRSM\'';
                }else if(pdcSelectionObj.Drain_Diameter__c >=5 && pdcSelectionObj.Drain_Diameter__c <=7){
                    query += ' AND Product2.ProductCode=\'C-CDSRMD\'';
                }else if(pdcSelectionObj.Drain_Diameter__c >=8 && pdcSelectionObj.Drain_Diameter__c <=10){
                    query += ' AND Product2.ProductCode=\'C-CDSRLG\'';
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM 2 SIDED THROUGH WALL SCUPPER W/ CLAD DROP'){
                System.debug('customProductType :: ' + customProductType);
                Decimal val = 0.00;
                if(pdcSelectionObj.Width__c != NULL &&  !(pdcSelectionObj.Width__c < 0)){
                    val +=  pdcSelectionObj.Width__c;
                }
                if(pdcSelectionObj.Length__c != NULL &&  !(pdcSelectionObj.Length__c < 0)) {
                    val += pdcSelectionObj.Length__c;
                }
                if(pdcSelectionObj.Height_H__c != NULL &&  !(pdcSelectionObj.Height_H__c < 0)) {
                    val += pdcSelectionObj.Height_H__c;
                }
                System.debug('val :: ' + val);
                if(val >= 0.00 && pdcSelectionObj.Width__c != NULL && pdcSelectionObj.Length__c != NULL &&  pdcSelectionObj.Height_H__c != NULL){
                    query += ' AND Product2.Maximum_Amount__c >=' + Integer.valueOf(val);
                    query += ' AND Product2.Minimum_Amount__c <=' + Integer.valueOf(val);
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM DECKSHIELD BY THE LINEAL FOOT'){
                System.debug('customProductType :: ' + customProductType);
                if(pdcSelectionObj.Product_Color__c != NULL &&  pdcSelectionObj.Product_Color__c != ''){
                    query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Product_Color__c + '\'';
                }
                pdeList = Database.query(query);
                
            }else if(customProductType == 'CUSTOM COVER STRIP WIDTH'){
                System.debug('customProductType :: ' + customProductType);
                if(pdcSelectionObj.Product_Color__c != NULL &&  pdcSelectionObj.Product_Color__c != ''){
                    query += ' AND Product2.Color_2__c = \'' + pdcSelectionObj.Product_Color__c + '\'';
                }
                pdeList = Database.query(query);
                
            }
            return pdeList;
        }
    }
    
    public class SetUnitPrice{
        public Decimal setUnitPrice(String customProductType, QuoteLineItem pdcSelectionObj){
            Decimal uPrice = 0.0;
            if(customProductType == 'CUSTOM DRIP EDGE WHITE'){
                uPrice = ((2.48*(pdcSelectionObj.Return_on_Deck__c + pdcSelectionObj.GS_length_W1__c + pdcSelectionObj.Height_H__c)) + (2.00*pdcSelectionObj.of_Bends__c)) + 5.00;
            }else if(customProductType == 'CUSTOM DRIP EDGE COLORS'){
                uPrice = ((2.73*(pdcSelectionObj.Return_on_Deck__c + pdcSelectionObj.GS_length_W1__c + pdcSelectionObj.Height_H__c)) + (2.00*pdcSelectionObj.of_Bends__c)) + 5.00;
            }else if(customProductType == 'CUSTOM DRIP EDGE STAINLESS'){
                uPrice = ((8.27*(pdcSelectionObj.Return_on_Deck__c + pdcSelectionObj.GS_length_W1__c + pdcSelectionObj.Height_H__c)) + (2.00*pdcSelectionObj.of_Bends__c)) + 5.00;
            }else if(customProductType == 'CUSTOM GALVANIZED CLEAT'){
                uPrice = ((1.83*(pdcSelectionObj.Return_on_Deck__c + pdcSelectionObj.Height_H__c)) + (2.00*pdcSelectionObj.of_Bends__c)) + 5.00;
            }else if(customProductType == 'CUSTOM STAINLESS CLEAT'){
                uPrice = ((8.27*(pdcSelectionObj.Return_on_Deck__c + pdcSelectionObj.Height_H__c)) + (2.00*pdcSelectionObj.of_Bends__c)) + 5.00;
            }else if(customProductType == 'CUSTOM DECKSHIELD BY THE LINEAL FOOT'){
                uPrice = (pdcSelectionObj.Length_Requested__c * pdcSelectionObj.Cost_Per_Lineal_Foot__c);
            }
            System.debug('Update_uPrice :: ' + uPrice);
            return uPrice.setscale(2);
        }
    }
}