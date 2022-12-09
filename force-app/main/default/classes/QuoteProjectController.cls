public class QuoteProjectController {
    
    public Project__c project;
    
    public Project__c projectAccount {get; set;}
    
    public List<AccountQuoteRow> accountQuoteList {get;set;}
    
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
    
    
    public QuoteProjectController(ApexPages.StandardController stdController) {
        system.debug('-----------Init--------');
    	
    	this.project = (Project__c)stdController.getRecord();
        
        this.projectAccount = new Project__c();
        
    	this.selectedQuoteList = new List<QuoteLineItem>();
    	this.productNames = new List<SelectOption>();
    	this.productColors = new List<SelectOption>();
    	this.productSizes = new List<SelectOption>();
    	
    	this.searchRows = new List<SearchRow>();
		this.quoteRows = new List<QuoteRow>();
		this.quoteRowMap = new Map<Id,QuoteRow>();
		
		this.accountQuoteList = new List<AccountQuoteRow>();

    }
    
    public PageReference safeAction() {

    	List<Pricebook2> pblist = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
    	
    	if (pblist.isEmpty()){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Pricebook Not Found!'));
    	}
    	this.pricebook = pblist.get(0);
    	
    	List<Project__c> pList = [SELECT Id, Name FROM Project__c WHERE Id = :this.project.Id];
    	
    	if (pList.isEmpty()){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Project Not Found!'));
    	}
    	this.project = pList.get(0);
    	
    	
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
    	
    	PageReference pageRef = Page.FinalizeQuote;
    	pageRef.setRedirect(false);
    	return pageRef;
    }
    
    public void addAccountToQuote(){
    	
    	List<Account> accountList = [SELECT Name,
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
    								 FROM Account 
    								 WHERE Id = :this.projectAccount.Account__c];
    	
    	for (Account acct : accountList){
    	
    		this.accountQuoteList.add(new AccountQuoteRow(this.project, this.pricebook, acct, this.quoteRows, this.totalQuotePrice));
    	}
    	
    	
    }
    
    public PageReference back(){
    	
    	//clear accounts if user goes back
    	this.accountQuoteList = new List<AccountQuoteRow>();
    	
    	PageReference pageRef = Page.QuoteProject;
    	pageRef.setRedirect(false);
    	return pageRef;
    }
    
    public PageReference saveQuote(){
    	
    	List<Opportunity> oppList = new List<Opportunity>();
    	List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    	
    	List<Quote> quoteList = new List<Quote>();
    	
    	List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    	
    	Set<Id> quoteIds = new Set<Id>();
    	
    	Savepoint sp = Database.setSavepoint();
    	
    	for (AccountQuoteRow aqrow : accountQuoteList){
    		oppList.add(aqrow.opp);
    	}
    	
    	try {
    		
    		insert oppList;
    		
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Opportunity!'));
    		return null;
    	}
    	
    	for (AccountQuoteRow aqrow : accountQuoteList){
    		aqrow.setOppIdOnQuote();
    		quoteList.add(aqrow.quoteObj);
    		oliList.addAll(aqrow.lineItemList);
    	}
    	
    	try {
    		insert oliList;
    	} catch (Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving OpportunityLineItems!'));
    		return null;
    	}
    	
    	try {
    		
    		insert quoteList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Quote!'));
    		return null;
    	}
    	
    	for (AccountQuoteRow aqrow : accountQuoteList){
    		quoteIds.add(aqrow.quoteObj.Id);
    		aqrow.setQuoteIdOnLineItems();
    		quoteLineItemList.addAll(aqrow.quoteLineItemList);
    	}
    	
    	try {
    		
    		insert quoteLineItemList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItems!'));
    		return null;
    	}
    	
    	insertQuoteTemplate(quoteIds);
    	
    	PageReference projPage = new ApexPages.StandardController(this.project).view();
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
    
    public class AccountQuoteRow {
    	
    	public Account acct {get;set;}
    	
    	public Opportunity opp {get;set;}
    	
    	public List<OpportunityLineItem> lineItemList;
    	
    	public Quote quoteObj {get;set;}
    	
    	//Project__c, BillingAddress, BillingName, ShippingName, ShippingAddress,  ShippingHandling, Tax, Email, ExpirationDate,	
    	// AccountId, OpportunityId Master-Detail(Opportunity)
    	
    	public List<QuoteLineItem> quoteLineItemList;
    	
    	
    	
    	public AccountQuoteRow(Project__c proj, Pricebook2 pricebook, Account acct, List<QuoteRow> quoteRowList, Decimal totalPrice){
    		this.acct = acct;
    		
    		this.opp = new Opportunity(Name = 'created by quick action',
    								   CloseDate = Date.today().addDays(14), // should this be user input?
    								   Project__c = proj.Id,
    								   AccountId = acct.Id,
    								   StageName = 'Estimating');
    		
    		
    		this.quoteObj = new Quote();
    		this.quoteObj.Name = proj.Name;
    		this.quoteObj.Project2__c = proj.Id;
    		this.quoteObj.Pricebook2Id = pricebook.Id;
    		
    		this.quoteObj.QuoteToName = acct.Primary_Contact__c;
    		this.quoteObj.Email = acct.Primary_Contact_Email__c;
    		
    		this.quoteObj.QuoteToStreet = acct.BillingStreet;
    		this.quoteObj.QuoteToCity = acct.BillingCity;
    		this.quoteObj.QuoteToState = acct.BillingState;
    		this.quoteObj.QuoteToPostalCode = acct.BillingPostalCode;
    		this.quoteObj.QuoteToCountry = acct.BillingCountry;
    		
    		// use cartItems ??
    		this.quoteLineItemList = new List<QuoteLineItem>();
    		this.lineItemList = new List<OpportunityLineItem>();
    		
    		for (QuoteRow qr :quoteRowList){
    			
    			this.quoteLineItemList.add(new QuoteLineItem(Product2Id = qr.productId, 
    														  Quantity = qr.quantity, 
    														  PricebookEntryId = qr.PricebookEntryId, 
    														  UnitPrice = qr.unitPrice, 
    														  Description = qr.specialNotes));
    														  
    			this.lineItemList.add(new OpportunityLineItem(Product2Id = qr.productId, 
    														  Quantity = qr.quantity, 
    														  PricebookEntryId = qr.PricebookEntryId, 
    														  UnitPrice = qr.unitPrice, 
    														  Description = qr.specialNotes));											  
    		}
    	}
    	
    	public void setOppIdOnQuote(){	
    		this.quoteObj.OpportunityId = this.opp.Id;
    		
    		for (OpportunityLineItem oli : this.lineItemList){
    			oli.OpportunityId = this.opp.Id;
    		}
    	}
    	
    	public void setQuoteIdOnLineItems(){
    		for (QuoteLineItem qli : this.quoteLineItemList){
    			qli.QuoteId = this.quoteObj.Id;
    		}
    	}
    }


}