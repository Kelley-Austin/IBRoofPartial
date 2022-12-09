public class ProjectQuoteController {
    
    private Opportunity opp;
    
    public String productSku {get; set;}
    
    public String productFamily {get;set;}
    public List<SelectOption> productNames {get; set;}
    public String productName {get; set;}
    public String productColor {get; set;}
    public List<SelectOption> productSizeItems {get; set;}
    public String productSize {get; set;}
    
    public List<QuoteLineItem> selectedQuoteList;
    
    public List<SearchRow> searchRows {get;set;}
    public List<CartRow> cartRows {get;set;}
    public Map<Id,CartRow> cartRowMap {get;set;}
    
    public Id selectedPricebookEntry {get;set;}
    public Id pricebookId;
    
    
    public ProjectQuoteController(ApexPages.StandardController stdController) {
    	system.debug('-----------Init--------');
    	
    	this.opp = (Opportunity)stdController.getRecord();
    	this.selectedQuoteList = new List<QuoteLineItem>();
    	this.productNames = new List<SelectOption>();
    	
    	this.searchRows = new List<SearchRow>();
		this.cartRows = new List<CartRow>();
		this.cartRowMap = new Map<Id,CartRow>();
    	
    } 
        
    public PageReference safeAction() {
    	
    	this.opp = [SELECT Id, Name, Pricebook2Id FROM Opportunity WHERE Id = :this.opp.Id];
    	
    	for (PricebookEntry pbe : [SELECT Id, Product2Id, Product2.Name, Product2.ProductCode, UnitPrice, Product2.Color__c, Product2.Product_Size__c, Product2.Thickness__c, Product2.Coverage__c, Product2.Weight__c, Product2.Package__c FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND IsActive=true]){
    		this.searchRows.add(new SearchRow(pbe)); 
    	}
    	
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

    	
    	system.debug('test');
    	
    	system.debug('this.selectedPricebook ->'+ this.selectedPricebookEntry);
    	
    	for (PricebookEntry pbe : [SELECT Id, Pricebook2Id, Product2Id, Product2.Name, UnitPrice FROM PricebookEntry WHERE Id = :this.selectedPricebookEntry]){
    		
    		if (this.cartRowMap.containsKey(pbe.Product2Id)) {
    			CartRow existingCr = this.cartRowMap.get(pbe.Product2Id);
    			existingCr.quantity += 1;
    			continue;
    		}
    		CartRow cr = new CartRow(pbe);
    		this.cartRows.add(cr);
    		this.cartRowMap.put(pbe.Product2Id, cr );
    		this.pricebookId = pbe.Pricebook2Id;
    	}

    	return null;
    }
    
    public PageReference runSearch() {
    	
    	String soql = 'SELECT Product2.Family, Product2.Name, Product2.ProductCode, Product2.Bulk_Box_Price__c, UnitPrice, Product2.Color__c, Product2.Product_Size__c, Product2.Thickness__c, Product2.Coverage__c, Product2.Weight__c, Product2.Package__c FROM PricebookEntry WHERE Pricebook2.IsStandard = true  AND IsActive=true';
    	String productDropdownSoql;
		if (String.isBlank(this.productSku) == false) {
			String skuContains = '%' + this.productSku +'%';
			soql += ' AND Product2.ProductCode LIKE :skuContains';
		} 
		
		if (String.isBlank(this.productFamily) == false) {
			soql += ' AND Product2.Family = :productFamily';
			productDropdownSoql = 'SELECT  Product2.Name FROM PricebookEntry WHERE Pricebook2.IsStandard = true AND Product2.Family = :productFamily  AND IsActive=true';
		}
		
		if (String.isBlank(this.productName) == false) {
			soql += ' AND Product2.Name = :productName';
		}
		
		if (String.isBlank(this.productColor) == false) {
			String colorContains = '%' + this.productColor +'%';
			soql += ' AND Product2.Color__c LIKE :colorContains';
		}
		
		if (String.isBlank(this.productSize) == false) {
			String sizeContains = '%' + this.productSize +'%';
			soql += ' AND Product2.Product_Size__c LIKE :sizeContains';
		}
		
		this.searchRows = new List<SearchRow>();
		
		List<PricebookEntry> searchedProductList = (List<PricebookEntry>) Database.query(soql);
    	
    	for (PricebookEntry pbe : searchedProductList){
    		this.searchRows.add(new SearchRow(pbe));
    	}
    	
    	if(productDropdownSoql != null) {
    		
	    	List<PricebookEntry> productList = (List<PricebookEntry>) Database.query(productDropdownSoql);
	    	
	    	this.productNames = new List<SelectOption>();
	    	this.productNames.add(new SelectOption('','--Select--'));
	    	
	    	for (PricebookEntry pbe : productList){
	    		this.productNames.add(new SelectOption(pbe.Product2.Name, pbe.Product2.Name));
	    	}
    	}
    	return null;
    }
    
    public PageReference save() {
    	
    	if (this.cartRows.isEmpty()) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Empty Cart'));
    		return null;
    	}
    	
    	Savepoint sp = Database.setSavepoint();
    	
    	try {
    		
    		Quote quote = new Quote(Name = this.opp.Name, Project__c = this.opp.Id, OpportunityId = this.opp.Id, Pricebook2Id = this.pricebookId);
    		insert quote;
    		
    		List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    		
    		for (CartRow cr: this.cartRows) {
    			quoteLineItemList.add( new QuoteLineItem (Product2Id = cr.productId, QuoteId = quote.Id, Quantity = cr.quantity, PricebookEntryId = cr.pricebookEntryId, UnitPrice = cr.price, Description = cr.specialNotes));
    		}
    		update quote;
    		insert quoteLineItemList;
    		
    	} catch (Exception e) {
    		
    		Database.rollback(sp);
    		
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Internal Problem, Please try again later'));
    		return null;
    	}
    	
    	PageReference page = new ApexPages.StandardController(this.opp).view();
        page.setRedirect(true);
        return page;
    	
    }
    
    public PageReference cancel() {
    	
    	PageReference page = new ApexPages.StandardController(this.opp).view();
        page.setRedirect(true);
        return page;
    }
    
    public class SearchRow {
    	
    	//checkbox
    	//public Boolean selected {get;set;}
    	
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
    	}
    }
    
    public class CartRow {
    	
    	public Integer quantity {get;set;}
    	public String productName {get;set;}
    	public Decimal price{get;set;}
    	public String specialNotes {get;set;}
    	public Id productId;
    	public Id pricebookEntryId;
    	
    	public CartRow(pricebookEntry pbe){

    		this.quantity = 1;
    		this.productId = pbe.Product2Id;
    		this.productName = pbe.Product2.Name;
    		this.pricebookEntryId = pbe.Id;
    		this.price = pbe.UnitPrice;
    	}
    	
    }

}