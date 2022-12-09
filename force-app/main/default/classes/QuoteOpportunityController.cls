public class QuoteOpportunityController {
	
	public Account accountObj;

	public Opportunity opportunityObj;
    	
	public Quote quoteObj {get;set;}
	
	//Project__c, BillingAddress, BillingName, ShippingName, ShippingAddress,  ShippingHandling, Tax, Email, ExpirationDate,	
	// AccountId, OpportunityId Master-Detail(Opportunity)
	
	public List<QuoteLineItem> quoteLineItemList;
	
    public String productSku {get; set;}
    
    public String productFamily {get;set;}
    public List<SelectOption> productNames {get; set;}
    public String productName {get; set;}
    public String productColor {get; set;}
    public List<SelectOption> productSizeItems {get; set;}
    public List<SelectOption> productColors {get; set;}
    public List<SelectOption> productSizes {get; set;}
    public String productSize {get; set;}
    
    public List<QuoteLineItem> selectedQuoteList;
    
    public String newProductSku {get; set;}
    public String newProductFamily {get;set;}
    public String newProductName {get; set;}
    public String newProductColor {get; set;}
    public String newProductSize {get; set;}
    public Decimal newProductPrice {get; set;}
    
    public List<SearchRow> searchRows {get;set;}
    public List<QuoteRow> quoteRows {get;set;}
    public Map<Id,QuoteRow> quoteRowMap {get;set;}
    
    public Id selectedPricebookEntry {get;set;}
    
    public Pricebook2 pricebook;
    
    // QUOTE TOTALS
    public Decimal totalQuoteWeight {get;set;}
    public Decimal totalQuotePrice {get;set;}
    
    public Integer selectedLine {get;set;}
    
    
    public QuoteOpportunityController(ApexPages.StandardController stdController) {
    	
    	this.opportunityObj = (Opportunity)stdController.getRecord();
        
        
    	this.selectedQuoteList = new List<QuoteLineItem>();
    	this.productNames = new List<SelectOption>();
    	this.productColors = new List<SelectOption>();
    	this.productSizes = new List<SelectOption>();
    	
    	this.searchRows = new List<SearchRow>();
		this.quoteRows = new List<QuoteRow>();
		this.quoteRowMap = new Map<Id,QuoteRow>();

    }
    
    public PageReference safeAction() {

    	List<Pricebook2> pblist = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
    	
    	if (pblist.isEmpty()){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Pricebook Not Found!'));
    	}
    	this.pricebook = pblist.get(0);
    	
    	List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id = :this.opportunityObj.Id];
    	
    	if (oppList.isEmpty() == true){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Opportunity Not Found!'));
    		return null;
    	}
    	
    	this.opportunityObj = oppList.get(0);
    	
    	List<Account> acctList = [SELECT Id,
										 Name,
										 Primary_Contact__c,
										 Primary_Contact_Email__c,
										 ShippingStreet,
										 ShippingCity,
										 ShippingState,
										 ShippingPostalCode,
										 ShippingCountry,
										 BillingStreet,
										 BillingCity,
										 BillingState,
										 BillingPostalCode,
										 BillingCountry    
								 FROM Account WHERE Id = :this.opportunityObj.AccountId];
								 
    	
    	if (acctList.isEmpty()){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Project Not Found!'));
    	}
    	this.accountObj = acctList.get(0);
    	

		this.quoteObj = new Quote();
		
		this.quoteObj.OpportunityId = this.opportunityObj.Id;
		this.quoteObj.Name = this.accountObj.Name;
		this.quoteObj.Pricebook2Id = this.pricebook.Id;
		
		
		this.quoteObj.QuoteToName = this.accountObj.Primary_Contact__c;
		this.quoteObj.Email = this.accountObj.Primary_Contact_Email__c;
		
		this.quoteObj.QuoteToStreet = this.accountObj.BillingStreet;
		this.quoteObj.QuoteToCity = this.accountObj.BillingCity;
		this.quoteObj.QuoteToState = this.accountObj.BillingState;
		this.quoteObj.QuoteToPostalCode = this.accountObj.BillingPostalCode;
		this.quoteObj.QuoteToCountry = this.accountObj.BillingCountry;
		
		
		// use cartItems ??
		this.quoteLineItemList = new List<QuoteLineItem>();

    	
    	this.productColors.add(new SelectOption('','--Select--'));
    	this.productSizes.add(new SelectOption('','--Select--'));
    	this.productNames.add(new SelectOption('','--Select--'));
    	
    	return null;
    }
    
    public List<SelectOption> getProductFamilys(){
    	
    	
    	List<SelectOption> productFamilyItems = new List<SelectOption>();
    	
    	Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
    	
    	productFamilyItems.add( new SelectOption( '', '--Select--' ));
    	
    	for (Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()) {
    		productFamilyItems.add( new SelectOption( pickListVal.getValue(), pickListVal.getLabel() ));
    	}
    	
    	return productFamilyItems;
    }
    
    public PageReference addtoCart(){
    	
    	
    	List<PricebookEntry> pbeList = [SELECT Id, 
    										   Pricebook2Id, 
    										   Product2Id,
    										   Product2.ProductCode, 
    										   Product2.Name,
    										   Product2.Color__c,
    										   Product2.Product_Size__c,
    										   Product2.Weight__c,
    										   Product2.Weight_lbs__c,
    										   Product2.Package__c,
    										   UnitPrice 
										FROM PricebookEntry 
										WHERE Id = :this.selectedPricebookEntry];
    	
    	for (PricebookEntry pbe : pbeList){
    		
    		//if (this.quoteRowMap.containsKey(pbe.Product2Id)) {
    		//	QuoteRow existingCr = this.quoteRowMap.get(pbe.Product2Id);
    		//	existingCr.quantity += 1;
    		//	continue;
    		//}
    		
    		QuoteRow cr = new QuoteRow(pbe, this.quoteRows.size());
    		this.quoteRows.add(cr);
    		this.quoteRowMap.put(pbe.Product2Id, cr );

    	}

    	return null;
    }

    
    public PageReference runSearch() {
    	
    	String soql = 'SELECT Product2.Family, Product2.Name, Product2.ProductCode, Product2.Bulk_Box_Price__c, UnitPrice, Product2.Color__c, Product2.Product_Size__c, Product2.Thickness__c, Product2.Coverage__c, Product2.Weight__c, Product2.Package__c FROM PricebookEntry WHERE Pricebook2.IsStandard = true  AND IsActive=true';
    	
    	if (String.isBlank(this.productSku) == false) {
			String skuContains = '%' + this.productSku +'%';
			soql += ' AND Product2.ProductCode LIKE :skuContains';
		} 
		
		if (String.isBlank(this.productFamily) == false) {
			soql += ' AND Product2.Family = :productFamily';
		}
		
		if (String.isBlank(this.productName) == false) {
			soql += ' AND Product2.Name = :productName';
		}
		
		if (String.isBlank(this.productColor) == false) {
			soql += ' AND Product2.Color__c = :productColor';
		}
		
		if (String.isBlank(this.productSize) == false) {
			soql += ' AND Product2.Product_Size__c LIKE :productSize';
		}
		
		this.searchRows = new List<SearchRow>();
		Set<String> colors = new Set<String>();
    	Set<String> sizes = new Set<String>();
		Set<String> productNameSet = new Set<String>();
		List<PricebookEntry> searchedProductList = (List<PricebookEntry>) Database.query(soql);
    	
    	for (PricebookEntry pbe : searchedProductList){
    		this.searchRows.add(new SearchRow(pbe));
    	}
    	
		for (PricebookEntry pbe : searchedProductList){
    		productNameSet.add(pbe.Product2.Name);
    		colors.add(pbe.Product2.Color__c);
			sizes.add(pbe.Product2.Product_Size__c);
    	}
    	
    	productNameSet.remove(null);
    	colors.remove(null);
		sizes.remove(null);
    	
    	this.productColors = new List<SelectOption>();
		this.productSizes = new List<SelectOption>();
		this.productNames = new List<SelectOption>();
    	
    	
    	this.productColors.add(new SelectOption('','--Select--'));
    	for (String s: colors) {
    		this.productColors.add(new SelectOption(s, s));
    	}
    	
    	this.productSizes.add(new SelectOption('','--Select--'));
    	for (String s: sizes) {
    		this.productSizes.add(new SelectOption(s, s));
    	}
    	
    	this.productNames.add(new SelectOption('','--Select--'));
    	for (String s: productNameSet) {
    		this.productNames.add(new SelectOption(s, s));
    	}
    	return null;
    }
    
    public PageReference finalizeQuote(){
    	
    	this.totalQuoteWeight = 0;
    	this.totalQuotePrice = 0;
    	
    	for (QuoteRow qr : quoteRows){
    		
    		if (qr.unitPrice == null || qr.unitPrice == 0){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You Must Enter a Unit Price for Each Item!'));
    			return null;
    		}
    		
    		if (qr.quantity == null || qr.quantity == 0){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You Must Enter a Quantity for Each Item!'));
    			return null;
    		}
    		
    		qr.generateTotals();
    		
    		this.totalQuoteWeight += qr.totalWeight;
    		this.totalQuotePrice += qr.totalPrice;
    	}
    	
    	PageReference pageRef = Page.FinalizeQuoteOpportunity;
    	pageRef.setRedirect(false);
    	return pageRef;
    }
    
    public PageReference back(){
    	
    	PageReference pageRef = Page.QuoteOpportunity;
    	pageRef.setRedirect(false);
    	return pageRef;
    }
    
    public PageReference saveQuote(){
    	
    	List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    	
    	List<OpportunitylineItem> deleteLineItemList = new List<OpportunityLineItem>();
    	List<OpportunitylineItem> lineItemList = new List<OpportunityLineItem>();
    	
    	Set<Id> quoteIds = new Set<Id>();
    	
    	Savepoint sp = Database.setSavepoint();

		for (Opportunity opp : [SELECT Id, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Id = :this.opportunityObj.Id]){
			deleteLineItemList.addAll(opp.OpportunityLineItems);
		}

    	try {
    		
    		delete deleteLineItemList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Deleting OpportunityLineItem!'));
    		return null;
    	}

    	try {
    		
    		insert this.quoteObj;
    		
    		quoteIds.add(this.quoteObj.Id);
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Quote!'));
    		return null;
    	}
    	
    	
    	for (QuoteRow qr :this.quoteRows){
    			
			quoteLineItemList.add(new QuoteLineItem (Product2Id = qr.productId,
													 QuoteId = this.quoteObj.Id,
													 Quantity = qr.quantity, 
													 PricebookEntryId = qr.PricebookEntryId, 
													 UnitPrice = qr.unitPrice, 
													 Description = qr.specialNotes));
													 
			lineItemList.add(new OpportunityLineItem(Product2Id = qr.productId,
													 OpportunityId = this.opportunityObj.Id,
													 Quantity = qr.quantity, 
													 PricebookEntryId = qr.PricebookEntryId, 
													 UnitPrice = qr.unitPrice, 
													 Description = qr.specialNotes));
		}
		
		try {
    		
    		insert lineItemList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving OpportunityLineItems!'));
    		return null;
    	}
    	
    	try {
    		
    		insert quoteLineItemList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItems!'));
    		return null;
    	}
    	
    	insertQuoteTemplate(quoteIds);

    	PageReference projPage = new ApexPages.StandardController(this.opportunityObj).view();
        projPage.setRedirect(true);
        return projPage;
    }
    
    public PageReference removeItem(){
    	
    	this.quoteRows.remove(this.selectedLine);
    	
    	for (Integer i = 0; i < this.quoteRows.size(); i++){
    		this.quoteRows.get(i).rowNumber = i;
    	}
    	
    	return null;
    }
    

    @future(callout=true)
	public static void insertQuoteTemplate(Set<Id> quoteIds) {
	    
	    List<QuoteDocument> docList = new List<QuoteDocument>();
	    
	    Quote_Template__c customSetting = Quote_Template__c.getOrgDefaults();
	    
	    try {
	    	
		    for (Id recordId :quoteIds){
		
			    PageReference pr = new PageReference('/quote/quoteTemplateDataViewer.apexp?id=' + recordId + '&summlid=' + customSetting.Id__c +'&headerHeight=100'); 
			
			    QuoteDocument qd = new QuoteDocument(); 
			    Blob b = pr.getContentAsPDF();
			
			    qd.Document = b;
			    qd.QuoteId = recordId;
			    
			    docList.add(qd);
		    }
	    
	    	insert docList;
	    	
	    } catch (Exception e){
	    	system.debug(e);
	    }
	    
	}
    
    public class SearchRow {
    	
    	
    	public Id pricebookEntryId {get;set;}
    	
    	//PRODUCT SKU
    	public String productSku {get;set;}
    	//PRODUCT NAME
    	public String productName {get;set;}
    	//COLOR
    	public String color {get;set;}
    	// SIZE
    	public String size {get;set;}
    	//THICKNESS
    	public String thickness {get;set;}
    	//WEIGHT (lbs)
    	public String weight {get;set;}
    	//COVERAGE (Sq Ft)
    	public String coverage {get;set;}
    	//PACKAGE per Pallet
    	public String packagePerPallet {get;set;}
    	//PRICE EACH
    	public Decimal priceEach {get;set;}
    	
    	public Boolean calculate {get;set;}
    	
    	public SearchRow(PricebookEntry pbe){
    		 
    		this.pricebookEntryId = pbe.Id;
    		this.productSku = pbe.Product2.ProductCode;
    		this.productName = pbe.Product2.Name;
    		this.color = pbe.Product2.Color__c;
    		this.size = pbe.Product2.Product_Size__c;
    		this.thickness = pbe.Product2.Thickness__c;
    		this.weight = pbe.Product2.Weight__c; 
    		this.coverage = pbe.Product2.Coverage__c;
    		this.packagePerPallet = pbe.Product2.Package__c;
    		this.priceEach = pbe.UnitPrice;
    		
    		this.calculate = (pbe.UnitPrice == 0);
    	}
    }
    
    
    public class QuoteRow {
    	
    	public Id productId;
    	public Id pricebookEntryId;
    	
    	public String productSku {get;set;}
    	public String productName {get;set;}
    	public String productColor {get;set;}
    	public String productSize {get;set;}
    	public String displayWeight {get;set;}
    	public Decimal productWeight {get;set;}
    	public String productPackage {get;set;}
    	
    	public String specialNotes {get;set;}
    	public Integer quantity {get;set;}
    	public Decimal unitPrice {get;set;}
    	
    	public Decimal totalPrice {get;set;} // price x quantity
    	public Decimal totalWeight {get;set;} // weight x quantity

    	public Integer rowNumber {get;set;}

    	public QuoteRow(pricebookEntry pbe, Integer rowNumber){
    		
    		this.rowNumber = rowNumber;

    		this.quantity = 1;
    		this.productId = pbe.Product2Id;
    		this.pricebookEntryId = pbe.Id;
    		
    		this.productSku = pbe.Product2.ProductCode;
    		this.productName = pbe.Product2.Name;
    		this.productColor = pbe.Product2.Color__c;
    		this.productSize = pbe.Product2.Product_Size__c;
    		this.displayWeight = pbe.Product2.Weight__c;
    		this.productWeight = pbe.Product2.Weight_lbs__c;
    		this.productPackage = pbe.Product2.Package__c;
    		
    		this.unitPrice = (pbe.UnitPrice == 0)? null : pbe.UnitPrice;
    		
    		system.debug('this.unitPrice -> '+ this.unitPrice);
    		
    		this.generateTotals();// check for null?
    	}
    	
    	public void generateTotals(){
    		
    		this.totalPrice = (this.unitPrice == null || this.quantity == null)? 0 : this.unitPrice * this.quantity;
    		
    		this.totalWeight = (this.productWeight == null || this.quantity == null)? 0 : this.productWeight * this.quantity;
    	}
    	
    }
    
}