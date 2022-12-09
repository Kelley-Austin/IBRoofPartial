global class QuoteEditController {
	
    public Account accountObj;
		
	public Opportunity opp {get;set;}
	public Quote quoteObj {get;set;}

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

    
    public Id selectedPricebookEntry {get;set;}
    
    public Pricebook2 pricebook;
    
    // QUOTE TOTALS
    public Decimal totalQuoteWeight {get;set;}
    public Decimal totalQuotePrice {get;set;}
    
	public Integer selectedLine {get;set;}
	
    public String uploadedFileString {get;set;}
    public Blob uploadedFile {get;set;}
    public String uploadedFileName {get;set;}
    public List<FileHolder> uploadedFiles {get;set;}
	public Integer selectedFile {get;set;}

	public Decimal currentTotalPrice;
	public Decimal estimatedTaxRate;
	public String taxRatePercentage {get;set;}

	public String projectAddress {get;set;}
    
    public QuoteEditController(ApexPages.StandardController stdController) {
    	
    	this.quoteObj = (Quote) stdController.getRecord();
        
    	this.selectedQuoteList = new List<QuoteLineItem>();
    	this.productNames = new List<SelectOption>();
    	this.productColors = new List<SelectOption>();
    	this.productSizes = new List<SelectOption>();
    	
    	this.searchRows = new List<SearchRow>();

		this.uploadedFiles = new List<FileHolder>();
    }
    
    public PageReference safeAction() {

    	List<Pricebook2> pblist = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
    	
    	if (pblist.isEmpty()){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Pricebook Not Found!'));
    	}
    	this.pricebook = pblist.get(0);
    	
        //removed acctlist
        if (this.quoteRows == null) {
            this.quoteRows = new List<QuoteRow>();

			List<Quote> quoteList = [SELECT Id,
											Special_Notes__c,
                                            Project2__c,
											Tax,
											TotalPrice,
                                            Name,
                                            QuoteToName,
                                            Pricebook2Id,
                                            Email,
                                            QuoteToStreet,
                                            QuoteToCity,
                                            QuoteToState,
                                            QuoteToPostalCode,
                                            QuoteToCountry,
											OpportunityId,
											(SELECT Id,
													OpportunityLineItemId,
                                                    Quantity, 
                                                    PricebookEntryId,
                                                    PricebookEntry.Product2.Name,
                                                    PricebookEntry.Pricebook2Id, 
                                                    PricebookEntry.Product2Id,
                                                    PricebookEntry.Product2.ProductCode,
                                                    PricebookEntry.Product2.Color__c,
                                                    PricebookEntry.Product2.Product_Size__c,
                                                    PricebookEntry.Product2.Weight__c,
                                                    PricebookEntry.Product2.Weight_lbs__c,
                                                    PricebookEntry.Product2.Package__c,
                                                    UnitPrice,
													Description,
													SortOrder
                                            FROM QuoteLineItems ORDER BY SortOrder)
                                    FROM Quote
                                    WHERE Id = :this.quoteObj.Id];

            if (quoteList.isEmpty()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Quote Not Found!'));
            }
            this.quoteObj = quoteList.get(0);
            
            for (QuoteLineItem qLI : this.quoteObj.QuoteLineItems) {
                QuoteRow cr = new QuoteRow(qLI, this.quoteRows.size());
                this.quoteRows.add(cr);
            }
        }

    	
    	this.productColors.add(new SelectOption('','--Select--'));
    	this.productSizes.add(new SelectOption('','--Select--'));
		this.productNames.add(new SelectOption('','--Select--'));
    	
    	return null;
	}

	public Pagereference setTaxAndShippingAddress() {
        this.setProjectShippingAddress();
        this.setEstimatedTaxAndLocalTaxRate();
        return null;
    }

    public Pagereference setProjectShippingAddress() {
        List<Project__c> projectList = [SELECT Id, Street__c, City__c, State__c, Zip__c, Country__c FROM Project__c WHERE Id = :this.quoteObj.Project2__c];
        
        if (projectList.isEmpty())
            return null;

        this.projectAddress = '';

        Project__c project = projectList.get(0);

        if (String.isBlank(project.Street__c) == false && String.isBlank(this.projectAddress) == false) {
            this.projectAddress += project.Street__c;
        } else {
            this.projectAddress = project.Street__c;
        }

        if (String.isBlank(project.City__c) == false && String.isBlank(this.projectAddress) == false) {
            this.projectAddress += ', ' + project.City__c;            
        } else {
            this.projectAddress = project.City__c;
        }

        if (String.isBlank(project.State__c) == false && String.isBlank(this.projectAddress) == false) {
            this.projectAddress += ', ' + project.State__c;            
        } else {
            this.projectAddress = project.State__c;
        }

        if (String.isBlank(project.Zip__c) == false && String.isBlank(this.projectAddress) == false) {
            this.projectAddress += ' ' + project.Zip__c; // zips dont add a comma?   
        } else {
            this.projectAddress = project.Zip__c;
        }

        if (String.isBlank(project.Country__c) == false && String.isBlank(this.projectAddress) == false) {
            this.projectAddress += ', ' + project.Country__c;            
        } else {
            this.projectAddress = project.Country__c;
        }

        return null;
    }

	public Pagereference setEstimatedTaxAndLocalTaxRate() {
		setLocalTaxRate();
		calculateEstimatedTax();
		return null;
	}

	public Pagereference setLocalTaxRate() {
		if (quoteObj.Project2__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Project must be selected to estimate tax'));
			return null;
		}

		List<Project__c> projectList = [SELECT Id, Tax_Rate__c, Zip__c FROM Project__c WHERE Id = :quoteObj.Project2__c];
		
		if (projectList.isEmpty() == true) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Project could not be found'));
			return null;
		}

		Project__c project = projectList.get(0);
		String zip = project.Zip__c;

		if (project.Tax_Rate__c != null) {
			AvalaraTaxRatesAPIService.TaxResponse taxResponse = (AvalaraTaxRatesAPIService.TaxResponse) JSON.deserialize(project.Tax_Rate__c, AvalaraTaxRatesAPIService.TaxResponse.class);
			this.estimatedTaxRate = taxResponse.totalRate;
			this.taxRatePercentage = String.valueOf((this.estimatedTaxRate * 100).setScale(2)) + '%';
			system.debug('tax rate already set! estimated tax rate -> ' + this.estimatedTaxRate);
			return null;
		}

		if (zip != null) {
			AvalaraTaxRatesAPIService.TaxResponse taxResponse;
			try {
				taxResponse = AvalaraTaxRatesAPIService.getTaxRates(zip, 'US');
			} catch (Exception e) {
				system.debug(e.getMessage());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Failed to get Tax Rate'));
				return null;
			}

			project.Tax_Rate__c = JSON.serialize(taxResponse);
			project.Tax_Rate_Updated_At__c = System.today();

			try {
				update project;
			} catch (Exception e) {
				system.debug(e.getMessage());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Project Tax Rate could not be updated!'));
				return null;
			}

			System.debug('new estimated tax rate set -> ' + taxResponse.totalRate);
			this.estimatedTaxRate = taxResponse.totalRate;
			this.taxRatePercentage = String.valueOf((this.estimatedTaxRate * 100).setScale(2)) + '%';
			return null;
		}

		this.quoteObj.Tax = 0.00;
		this.estimatedTaxRate = null;
		this.taxRatePercentage = null;
		system.debug('No zip code associated with selected project');
		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'No zip code associated with selected project'));
		return null;
	}

	public void calculateEstimatedTax() {
		this.currentTotalPrice = 0;

		if (this.estimatedTaxRate == null)
			return;

		for (QuoteRow qr : this.quoteRows) {
			// this.currentTotalPrice += qr.unitPrice;
			qr.generateTotals();
			this.currentTotalPrice += qr.totalPrice;
		}

		this.quoteObj.Tax = this.currentTotalPrice * this.estimatedTaxRate;
	}
	
	public Pagereference addFile(){
        system.debug('uploaded file name -> ' + this.uploadedFileName);
        this.uploadedFile = EncodingUtil.base64Decode(this.uploadedFileString);
        system.debug('uploaded file is null? -> ' + this.uploadedFile == null);
        if (this.uploadedFileName == null || this.uploadedFile == null)
			return null;

		ContentVersion cv = new ContentVersion(VersionData = this.uploadedFile, Title = this.uploadedFileName, ContentLocation = 's', PathOnClient = this.uploadedFileName);

		Savepoint sp = Database.setSavepoint();

		try {
			insert cv;
		} catch(Exception e){
			Database.rollback(sp);
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Content Version!'));
			return null;
		}

		this.uploadedFiles.add(new FileHolder(this.uploadedFileName, cv.Id, this.uploadedFiles.size()));
		this.uploadedFileString = null;
        this.uploadedFileName = null;
        this.uploadedFile = null;
        return null;
    }

    public Pagereference removeFile() {
        system.debug('selected file -> ' + this.selectedFile);
        if (this.selectedFile == null || this.selectedFile >= this.uploadedFiles.size())
			return null;
			
		Id contentVersionId = this.uploadedFiles.get(this.selectedFile).contentVersionId;
		List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId];

		if (contentVersions.isEmpty() == true) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Removing Content Document! Content Version not found!'));
			return null;
		}

		ContentDocument cd = new ContentDocument(Id = contentVersions.get(0).ContentDocumentId);

		Savepoint sp = Database.setSavepoint();

		try {
			delete cd;
		} catch(Exception e){
			Database.rollback(sp);
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Removing Content Document!'));
			return null;
		}

        this.uploadedFiles.remove(this.selectedFile);
        
        for (Integer i = 0; i < this.uploadedFiles.size(); i++){
            this.uploadedFiles.get(i).index = i;
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
    		
    		QuoteRow cr = new QuoteRow(pbe, this.quoteRows.size());
            this.quoteRows.add(cr);
            
    	}

    	return null;
    }
    
    public PageReference selectProductFamily(){
    	
    	this.productSku = null;
    	this.productName = null;
    	this.productColor = null;
    	this.productSize = null;
    	
    	return this.runSearch();
    	
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
        
		system.debug(soql);
        
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
		
		this.setProjectShippingAddress();
		this.setLocalTaxRate();
		
		if (this.quoteObj.Tax == null || this.quoteObj.Tax == 0.00)
			this.calculateEstimatedTax();
	
    	PageReference pageRef = Page.FinalizeQuoteEdit;
    	pageRef.setRedirect(false);
    	return pageRef;
    }
    
    public PageReference back(){
    	
    	PageReference pageRef = Page.QuoteEdit;
    	pageRef.setRedirect(false);
    	return pageRef;
    }
    
    public PageReference saveQuote(){
    	
    	List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    	
    	Set<Id> quoteIds = new Set<Id>{this.quoteObj.Id};
    	
    	if (String.isBlank(this.quoteObj.Project2__c)){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You must select an existing project or create a new project!'));
    		return null;
		}
		
		if (this.quoteObj.Pricebook2Id == null) {
			List<Pricebook2> pblist = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
    	
			for (Pricebook2 pricebook : pblist) {
				this.quoteObj.Pricebook2Id = pricebook.Id;
			}
		}
    	
    	Savepoint sp = Database.setSavepoint();
    	
    	try {
    		
    		update this.quoteObj;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Quote!'));
    		return null;
    	}
    	
        Set<Id> quoteLineItemIds = new Set<Id>();
    
        for (QuoteRow qr : this.quoteRows) {
            quoteLineItemIds.add(qr.quoteLineItemId);
        }
        quoteLineItemIds.remove(null);

        List<QuoteLineItem> deleteList = [SELECT Id, OpportunityLineItemId FROM QuoteLineItem WHERE Id NOT IN :quoteLineItemIds AND QuoteId = :this.quoteObj.Id];
		
		Set<Id> oliIdsToDelete = new Set<Id>();
		for (QuoteLineItem qli : deleteList) {
			oliIdsToDelete.add(qli.OpportunityLineItemId);
		}
		oliIdsToDelete.remove(null);

		List<OpportunityLineItem> oppDeleteList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIdsToDelete AND OpportunityId = :this.quoteObj.OpportunityId];

        try {
            delete oppDeleteList;
        } catch (Exception e) {
            Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Quote please contact your system administrator!'));
    		return null;
        }

        try {
            delete deleteList;
        } catch (Exception e) {
            Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItem!'));
    		return null;
		}
		
		Set<Id> oppUpsertIds = new Set<Id>();
		for (QuoteRow qr :this.quoteRows) {
			if (qr.OpportunityLineItemId != null)
				oppUpsertIds.add(qr.OpportunityLineItemId);
		}

		Map<Id,OpportunityLineItem> oliById = new Map<Id,OpportunityLineItem>([SELECT Id FROM OpportunityLineItem WHERE Id IN :oppUpsertIds]);

        List<OpportunityLineItem> oppUpsertList = new List<OpportunityLineItem>();

		Integer oliSortOrder = 0;
        for (QuoteRow qr :this.quoteRows) {
			oliSortOrder++;
			OpportunityLineItem oppLI;
            if (oliById.get(qr.OpportunityLineItemId) != null) {
                oppLI = oliById.get(qr.OpportunityLineItemId);
                //oppLI.Product2Id = quoteLI.product2Id;
                oppLI.Quantity = qr.quantity; 
                //oppLI.PricebookEntryId = quoteLI.PricebookEntryId; 
                oppLI.UnitPrice = qr.unitPrice; 
				oppLI.Description = qr.specialNotes;
				oppLI.SortOrder = oliSortOrder;
            } else {
				oppLI = new OpportunityLineItem(SortOrder = oliSortOrder,
                                        Product2Id = qr.productId,
                                        OpportunityId = this.quoteObj.OpportunityId,
                                        Quantity = qr.quantity, 
                                        PricebookEntryId = qr.PricebookEntryId, 
                                        UnitPrice = qr.unitPrice, 
                                        Description = qr.specialNotes);
			}
			oppUpsertList.add(oppLI);
			qr.oli = oppLI; // this is so we can get the oli id when upserting quote line items
        }

        try {
    		
    		upsert oppUpsertList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItem!'));
    		return null;
		}
		
		Integer qliSortOrder = 0;
		for (QuoteRow qr :this.quoteRows){
    		qliSortOrder++;
			quoteLineItemList.add(new QuoteLineItem (Id = qr.quoteLineItemId,
													 SortOrder = qliSortOrder,
													 OpportunityLineItemId = qr.oli.Id, // should always have an id because they were just upserted
                                                     Product2Id = qr.productId,
													 QuoteId = this.quoteObj.Id,
													 Quantity = qr.quantity, 
													 PricebookEntryId = qr.PricebookEntryId, 
													 UnitPrice = qr.unitPrice, 
													 Description = qr.specialNotes));							 
		}
    	
    	try {
    		
    		upsert quoteLineItemList;
    	
    	} catch(Exception e){
    		Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItem!'));
    		return null;
        }

        // (Quote_Line_Item__c = quoteLine.Id,
        // Product2Id = quoteLine.product2Id,
        // OpportunityId = this.quoteObj.OpportunityId,
        // Quantity = quoteLine.quantity, 
        // PricebookEntryId = quoteLine.PricebookEntryId, 
        // UnitPrice = quoteLine.unitPrice, 
		// Description = quoteLine.Description
		
		Set<Id> contentVersionIds = new Set<Id>();

		for (FileHolder file : this.uploadedFiles) {
			contentVersionIds.add(file.contentVersionId);
		}
        
        List<ContentVersion> insertedContentVersions = new List<ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]);

        system.debug('inserted content versions -> ' + insertedContentVersions);

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        for (ContentVersion cv : insertedContentVersions) {
            contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId, LinkedEntityId = quoteObj.Id));
        }

        system.debug('content document links -> ' + contentDocumentLinks);

        try {
            insert contentDocumentLinks;
        } catch (Exception e) {
            Database.rollback(sp);
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItems!'));
    		return null;
        }
    	
    	insertQuoteTemplate(quoteIds);

    	PageReference quotePage = new ApexPages.StandardController(this.quoteObj).view();
        quotePage.setRedirect(true);
        return quotePage;
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
		
			    PageReference pr = new PageReference('/quote/quoteTemplateDataViewer.apexp?id=' + recordId + '&summlid=' + customSetting.Id__c +'&headerHeight=100&bodyHeight=300&footerHeight=160'); 
			
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
    	public Id quoteLineItemId;
    	public Id productId;
		public Id pricebookEntryId;

		public Id OpportunityLineItemId;
		public OpportunityLineItem oli;
		
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

        public QuoteRow(QuoteLineItem quoteLine, Integer rowNumber){
            this.quoteLineItemId = quoteLine.Id;
    		
    		this.rowNumber = rowNumber;
    		
            this.quantity = (Integer) quoteLine.Quantity;
            this.specialNotes = quoteLine.Description;
            
    		this.productId = quoteLine.PricebookEntry.Product2Id;
			this.pricebookEntryId = quoteLine.PricebookEntry.Id;
			this.OpportunityLineItemId = quoteLine.OpportunityLineItemId;
    		
    		this.productSku = quoteLine.PricebookEntry.Product2.ProductCode;
    		this.productName = quoteLine.PricebookEntry.Product2.Name;
    		this.productColor = quoteLine.PricebookEntry.Product2.Color__c;
    		this.productSize = quoteLine.PricebookEntry.Product2.Product_Size__c;
    		this.displayWeight = quoteLine.PricebookEntry.Product2.Weight__c;
    		this.productWeight = quoteLine.PricebookEntry.Product2.Weight_lbs__c;
    		this.productPackage = quoteLine.PricebookEntry.Product2.Package__c;
    		
    		this.unitPrice = (quoteLine.UnitPrice == 0) ? null : quoteLine.UnitPrice;
    		
    		this.generateTotals();// check for null?
        }
    	
    	public void generateTotals(){
    		
    		this.totalPrice = (this.unitPrice == null || this.quantity == null)? 0 : this.unitPrice * this.quantity;
    		
    		this.totalWeight = (this.productWeight == null || this.quantity == null)? 0 : this.productWeight * this.quantity;
    	}
    	
	}
	
	@RemoteAction
	global static List<Project__c> getRecentProjects() {
		List<Project__c> recentProjects = [SELECT Id, Name, Street__c, City__c, State__c FROM Project__c ORDER BY LastViewedDate DESC LIMIT 5];
		return recentProjects;
	}

	@RemoteAction
	global static List<Project__c> searchProjects(String searchText) {
		String searchTerm = '%' + searchText + '%';
		List<Project__c> projectSearchResults = [SELECT Id, Name, Street__c, City__c, State__c FROM Project__c WHERE Name LIKE :searchTerm LIMIT 10];
		return projectSearchResults;
	}

	@RemoteAction
	global static String getCurrentUserName() {
		return UserInfo.getName();
	}

	@RemoteAction
	global static Project__c insertNewProject(String newProjectJSON) {
		Project__c newProject = (Project__c) JSON.deserialize(newProjectJSON, Project__c.class);
		try {
			insert newProject;
		} catch (Exception e) {
			system.debug(e);
			return null;
		}
		return newProject;
    }
    
    @RemoteAction
	global static Project__c getProjectById(Id projectId) {
        List<Project__c> projectList = [SELECT Id, Name, Street__c, City__c, State__c FROM Project__c WHERE Id = :projectId];
        Project__c projectById = null;

		for (Project__c project : projectList) {
            projectById = project;
        }

        return projectById;
	}

	public class FileHolder {
        public String name {get;set;}
        public Id contentVersionId {get;set;}
        public Integer index {get;set;}

        public FileHolder(String name, Id contentVersionId, Integer idx) {
            this.name = name;
            this.contentVersionId = contentVersionId;
            this.index = idx;
        }
    }
}