@isTest
private class AddUpdateQuoteLineItemControllerTest {
	@testSetup static void setup() {
        Account a = new Account(Name='test',Phone='1231231234',BillingCity='Roseville',BillingState='CA',BillingPostalCode='123123');
		insert a;

        Project__c project = new Project__c(Zip__c = '95758', Tax_Rate__c = '{"totalRate":0.072500,"rates":[{"type":"County","rate":0.002500,"name":"CA COUNTY TAX"},{"type":"State","rate":0.060000,"name":"CA STATE TAX"},{"type":"Special","rate":0.010000,"name":"CA SPECIAL TAX"}]}');
        insert project;
        
        Product2 p = new Product2(Name = 'test', Family = 'VENTS', ProductCode = '1-50w', Bulk_Box_Price__c = 10.00, Color__c = 'red', Product_Size__c = '1', CommercientSF__ExternalKey__c = 'test');
        insert p;
        
		/*Product2 pCMW = new Product2(Name = 'Custom Metal White', Family = 'CUSTOM', ProductCode = 'C-MW', Bulk_Box_Price__c = 10.00, Color__c = 'red', Product_Size__c = '1', CommercientSF__ExternalKey__c = 'test');
        insert pCMW;*/
        
        Opportunity opp = new Opportunity(AccountId=a.Id, Name='test', StageName='New',CloseDate=Date.today());
        insert opp;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(UnitPrice = 11.00, Product2Id = p.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
		insert pbe;
        
        /*PricebookEntry pbeCMW = new PricebookEntry(UnitPrice = 11.00, Product2Id = pCMW.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
		insert pbeCMW;*/
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,Product2Id=p.Id,Quantity = 1,PricebookEntryId = pbe.Id,UnitPrice = 12);
        insert oli;
        
        Quote quote = new Quote(Name = a.Name, OpportunityId = opp.Id, Account__c = a.Id, Pricebook2Id = standardPricebook.Id, Shipping_Zip_Postal_Code__c=99501, Project2__c = project.Id);
        insert quote;

        QuoteLineItem qli = new QuoteLineItem(Product2Id = p.Id, QuoteId = quote.Id,Quantity = 1,PricebookEntryId = pbe.Id,UnitPrice = 12,Description = '', OpportunityLineItemId = oli.Id);
        insert qli;

        QuoteLineItem qli2 = new QuoteLineItem(Product2Id = p.Id, QuoteId = quote.Id,Quantity = 1,PricebookEntryId = pbe.Id,UnitPrice = 12,Description = '', OpportunityLineItemId = oli.Id);
        insert qli2;
        
        Custom_Product_Type__c customFindType = new Custom_Product_Type__c(Name = 'Custom 2 Sided Through Wall Scupper w/ Clad Drop - Add Products',Object_API_Name__c = 'QuoteLineItem',Product_Type__c='Custom 2 Sided Through Wall Scupper w/ Clad Drop', View_Type__c = 'Find Product');
        insert customFindType;
        
        Custom_Product_Type__c customAddType = new Custom_Product_Type__c(Name = 'Custom Drip Edge White - Add Product',Object_API_Name__c = 'QuoteLineItem',Product_Type__c='Custom Drip Edge White', View_Type__c = 'Add Product');
        insert customAddType;
        
        List<Custom_Product_Fields__c> customFieldList = new List<Custom_Product_Fields__c>();
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Product2.ProductCode', Find_Product_Display_Order__c = 0, Name = 'Product SKU', Order__c = 1, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Product2.Name', Find_Product_Display_Order__c = 0, Name = 'Product Name', Order__c = 2, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Product2.Color__c', Find_Product_Display_Order__c = 0, Name = 'Color', Order__c = 3, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Product2.Product_Size__c', Find_Product_Display_Order__c = 0, Name = 'Size', Order__c = 4, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Product2.Thickness__c', Find_Product_Display_Order__c = 0, Name = 'Thickness', Order__c = 5, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Product2.Weight__c', Find_Product_Display_Order__c = 0, Name = 'Weight (LBS)', Order__c = 6, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'Quantity', Find_Product_Display_Order__c = 0, Name = 'Quantity', Order__c = 7, Read_Only__c = false, Required__c = true));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'UnitPrice', Find_Product_Display_Order__c = 0, Name = 'UnitPrice', Order__c = 8, Read_Only__c = false, Required__c = true));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customFindType.Id, Field_API_Name__c = 'ListPrice', Find_Product_Display_Order__c = 0, Name = 'ListPrice', Order__c = 9, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Product2.ProductCode', Find_Product_Display_Order__c = 0, Name = 'Product SKU', Order__c = 1, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Product2.Name', Find_Product_Display_Order__c = 0, Name = 'Product Name', Order__c = 2, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Product2.Color__c', Find_Product_Display_Order__c = 0, Name = 'Color', Order__c = 3, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Product2.Product_Size__c', Find_Product_Display_Order__c = 0, Name = 'Size', Order__c = 4, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Product2.Thickness__c', Find_Product_Display_Order__c = 0, Name = 'Thickness', Order__c = 5, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Product2.Weight__c', Find_Product_Display_Order__c = 0, Name = 'Weight (LBS)', Order__c = 6, Read_Only__c = true, Required__c = false));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'Quantity', Find_Product_Display_Order__c = 0, Name = 'Quantity', Order__c = 7, Read_Only__c = false, Required__c = true));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'UnitPrice', Find_Product_Display_Order__c = 0, Name = 'UnitPrice', Order__c = 8, Read_Only__c = false, Required__c = true));
        customFieldList.add(new Custom_Product_Fields__c(Custom_Product_Type__c = customAddType.Id, Field_API_Name__c = 'ListPrice', Find_Product_Display_Order__c = 0, Name = 'ListPrice', Order__c = 9, Read_Only__c = true, Required__c = false));
        insert customFieldList;
    }

    static testMethod void testGetProductType() {
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        Map<String, Object> result = AddUpdateQuoteLineItemController.getProductType(qt.Id);
        //System.assert(result.containsKey('pfamily'));

        Product2 p = [SELECT CommercientSF__ExternalKey__c FROM Product2 LIMIT 1];
        p.CommercientSF__ExternalKey__c = NULL;
        update p;
        result = AddUpdateQuoteLineItemController.getProductType(qt.Id);
        //System.assertEquals(result.get('error'),'No Product Found.');
        Test.stopTest();
    }
    
    static testMethod void testGetProductByType() {
        Test.startTest();
        Map<String, Object> result = AddUpdateQuoteLineItemController.getProductByType('VENTS');
        //System.assert(result.containsKey('result'));
        result = AddUpdateQuoteLineItemController.getProductByType('TEST');
        System.assert(result.containsKey('error'));
        Test.stopTest();
    }
    
    static testMethod void testGetProductBySearchTerm() {
        Test.startTest();
        String searchStr = '{"pdcName":"test","pdcColor":"red","pdcType":"VENTS","searchStr":"1-50w","pdcSize":"1"}';
        Map<String, Object> result = AddUpdateQuoteLineItemController.getProductBySearchTerm(searchStr);
        //System.assert(result.containsKey('result'));
        
        searchStr = '{"pdcName":"testing","pdcColor":"black","pdcType":"VENTS","searchStr":"1-50w","pdcSize":"1"}';
        result = AddUpdateQuoteLineItemController.getProductBySearchTerm(searchStr);
        //System.assert(result.containsKey('error'));
        Test.stopTest();
    }
    
    static testMethod void testAddQuoteLineItem() {
        Quote q = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        Test.startTest();
        String recordData = '{"Description":"","Quantity":"1","UnitPrice":"16","OpportunityLineItemId":"'+q.OpportunityId +'","PricebookEntryId":"'+pbe.Id+'","Product2Id":"'+pbe.Product2Id+'","QuoteId":"'+q.Id+'"}';
        Map<String, Object> result = AddUpdateQuoteLineItemController.addQuoteLineItem(recordData,'');
        //System.assert(result.containsKey('newQuoteLineItem'));
        Test.stopTest();
    }
    
    static testMethod void testDeleteQuoteLineItem() {
        QuoteLineItem qli = [SELECT Id, QuoteId FROM QuoteLineItem LIMIT 1];
        Test.startTest();
        Map<String, Object> result = AddUpdateQuoteLineItemController.deleteQuoteLineItem(qli.Id,qli.QuoteId);
        //System.assert(result.containsKey('result'));
        result = AddUpdateQuoteLineItemController.deleteQuoteLineItem(qli.Id,'0Q08B000000ESKqSAO');
        //System.assert(result.containsKey('error'));
        Test.stopTest();
    }

    static testMethod void testUpdateQuoteLineItem() {
        QuoteLineItem qli = [SELECT Id, QuoteId FROM QuoteLineItem LIMIT 1];
        String qliToUpdate = '{"Id":"'+qli.Id+'","specialNotes":"test","quantity":"1","unitprice":"16"}';
        Test.startTest();
        Map<String, Object> result = AddUpdateQuoteLineItemController.updateQuoteLineItem(qliToUpdate,qli.QuoteId);
        //System.assert(result.containsKey('success'));
        Test.stopTest();
    }
    
    static testMethod void testGetCustomFindProductFields() {
        Test.startTest();
        Map<String, Object> result = AddUpdateQuoteLineItemController.getCustomFindProductFields('Custom 2 Sided Through Wall Scupper w/ Clad Drop');
        //System.assert(result.containsKey('customFindProductFields'));
        //System.assert(result.containsKey('customFindProductType'));
        
        result = AddUpdateQuoteLineItemController.getCustomFindProductFields('Dummy');
        //System.assert(result.containsKey('error'));
        Test.stopTest();
    }
    
    static testMethod void testGetCustomAddProductFields() {
        QuoteLineItem qli = [SELECT Id, QuoteId FROM QuoteLineItem LIMIT 1];
        String findPdcVal = JSON.serialize(qli); 
        Test.startTest();
        Map<String, Object> result = AddUpdateQuoteLineItemController.getCustomAddProductFields(qli.QuoteId,'Custom Drip Edge White',findPdcVal);
        //System.assert(result != null);
        Test.stopTest();
    }

    static testMethod void testGetPriceBookEntryList() {
        QuoteLineItem qli = [SELECT Id, QuoteId FROM QuoteLineItem LIMIT 1];
        qli.Product_Color__c = 'red';
        qli.Bottom_Diameter_BD__c = 1;
        qli.Height_H__c = 1;

        String customProductType = 'CUSTOM CONE';
        Test.startTest();
        AddUpdateQuoteLineItemController.SetProductSelectionQuery setCtlr = new AddUpdateQuoteLineItemController.SetProductSelectionQuery();
        String query = 'SELECT Id, Pricebook2Id, Product2Id';
        query += ' FROM PricebookEntry WHERE Product2.CommercientSF__ExternalKey__c!=NULL AND Pricebook2.IsStandard = true  AND IsActive=true AND Product2.Family=\''+customProductType+'\'';
        List<PricebookEntry> result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        qli.Product_Color__c = 'red';
        qli.Bottom_Diameter_BD__c = 1;
        qli.Height_H__c = null;
        result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        qli.Product_Color__c = 'red';
        qli.Bottom_Diameter_BD__c = null;
        qli.Height_H__c = 1;
        result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        qli.Product_Color__c = 'red';
        qli.Color_Metal__c = 'red';
        qli.Drain_Diameter__c = 1;
        qli.Width_Upper__c = 1;
        qli.Length_Upper__c = 1;
        qli.Width__c = 1;
        qli.Length__c = 1;
        qli.Height_H__c = 1;
        
        customProductType = 'CUSTOM PITCH PAN';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM POST FLASHING';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM POST FLASHING';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM OVERFLOW SCUPPER';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM DRIP EDGE WHITE';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM DRIP EDGE COLORS';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);

		customProductType = 'CUSTOM DRIP EDGE STAINLESS';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
		customProductType = 'CUSTOM GALVANIZED CLEAT';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM STAINLESS CLEAT';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM DRAIN LINER';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM CLAD METAL DROP SCUPPER ROUND';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        qli.Drain_Diameter__c = 6;
        result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        qli.Drain_Diameter__c = 9;
        result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM 2 SIDED THROUGH WALL SCUPPER W/ CLAD DROP';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM DECKSHIELD BY THE LINEAL FOOT';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        customProductType = 'CUSTOM COVER STRIP WIDTH';
		result = setCtlr.getPriceBookEntryList(customProductType, qli, query);
        
        Test.stopTest();
    }
    
    static testMethod void testSetUnitPrice() {
        QuoteLineItem qli = [SELECT Id, QuoteId, Return_on_Deck__c, GS_length_W1__c, Height_H__c, of_Bends__c, Length_Requested__c, Cost_Per_Lineal_Foot__c FROM QuoteLineItem LIMIT 1];
        qli.Return_on_Deck__c = 1;
        qli.GS_length_W1__c = 1;
        qli.Height_H__c = 1;
        qli.of_Bends__c = 1;
        qli.Length_Requested__c = 1;
        qli.Cost_Per_Lineal_Foot__c = 1;
        String customProductType = 'CUSTOM DRIP EDGE WHITE';
        Test.startTest();
        AddUpdateQuoteLineItemController.SetUnitPrice setCtlr = new AddUpdateQuoteLineItemController.SetUnitPrice();
        Decimal result = setCtlr.setUnitPrice(customProductType, qli);
        result = setCtlr.setUnitPrice(customProductType, qli);
        
        customProductType = 'CUSTOM DRIP EDGE COLORS';
        result = setCtlr.setUnitPrice(customProductType, qli);
        
        customProductType = 'CUSTOM DRIP EDGE STAINLESS';
        result = setCtlr.setUnitPrice(customProductType, qli);
        
        customProductType = 'CUSTOM GALVANIZED CLEAT';
        result = setCtlr.setUnitPrice(customProductType, qli);
        
        customProductType = 'CUSTOM STAINLESS CLEAT';
        result = setCtlr.setUnitPrice(customProductType, qli);
        
        customProductType = 'CUSTOM DECKSHIELD BY THE LINEAL FOOT';
        result = setCtlr.setUnitPrice(customProductType, qli);
        Test.stopTest();
    }
    
    @isTest
    public static void testController(){
        // Map<String, Object> result1 = AddUpdateQuoteLineItemController.getProductType(quote.Id);
        // Map<String, Object> result2 = AddUpdateQuoteLineItemController.getProductType(a.Id);
        
        // Map<String, Object> result3 = AddUpdateQuoteLineItemController.getProductByType(p.Family);
        // Map<String, Object> result4 = AddUpdateQuoteLineItemController.getProductByType('');
        
        // Map<String, Object> result5 = AddUpdateQuoteLineItemController.getProductBySearchTerm('');
        // String searchStr = '{"pdcType":"VENTS","pdcName":"test","pdcColor":"red","pdcSize":"1","searchStr":"t"}';
        // Map<String, Object> result6 = AddUpdateQuoteLineItemController.getProductBySearchTerm(searchStr);
        
        // String recordData = '{"Description":"","Quantity":"1","UnitPrice":"16","OpportunityLineItemId":"'+opp.Id +'","PricebookEntryId":"'+pbe.Id+'","Product2Id":"'+p.Id+'","QuoteId":"'+quote.Id+'"}';
        // System.debug('recordDate ## ' + recordData);
        // Map<String, Object> result7 = AddUpdateQuoteLineItemController.addQuoteLineItem(recordData,'');
        
        // String qliToUpdate = '{"Id":"'+qli.Id+'","specialNotes":"test","quantity":"1","unitprice":"16"}';
        // Map<String, Object> result8 = AddUpdateQuoteLineItemController.updateQuoteLineItem(qliToUpdate,quote.Id);
        
        // Map<String, Object> result9 = AddUpdateQuoteLineItemController.deleteQuoteLineItem(qli2.Id,quote.Id);
    }
}