global class QuoteAccountController {
    
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
    
    public QuoteAccountController(ApexPages.StandardController stdController) {
        
        this.accountObj = (Account)stdController.getRecord();
        this.selectedQuoteList = new List<QuoteLineItem>();
        this.productNames = new List<SelectOption>();
        this.productColors = new List<SelectOption>();
        this.productSizes = new List<SelectOption>();

        this.searchRows = new List<SearchRow>();
        this.quoteRows = new List<QuoteRow>();

        this.uploadedFiles = new List<FileHolder>();
    }
    
    public PageReference safeAction() {

        List<Pricebook2> pblist = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        
        if (pblist.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Pricebook Not Found!'));
        }
        this.pricebook = pblist.get(0);
        
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
                                 FROM Account WHERE Id = :this.accountObj.Id];
                                 
        
        if (acctList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Project Not Found!'));
        }
        this.accountObj = acctList.get(0);
        

        this.quoteObj = new Quote();
        this.quoteObj.ExpirationDate = Date.today().addMonths(1);
        this.quoteObj.Name = this.accountObj.Name;
        this.quoteObj.Pricebook2Id = this.pricebook.Id;
        
        this.quoteObj.QuoteToName = this.accountObj.Primary_Contact__c;
        this.quoteObj.Email = this.accountObj.Primary_Contact_Email__c;
        
        this.quoteObj.QuoteToStreet = this.accountObj.BillingStreet;
        this.quoteObj.QuoteToCity = this.accountObj.BillingCity;
        this.quoteObj.QuoteToState = this.accountObj.BillingState;
        this.quoteObj.QuoteToPostalCode = this.accountObj.BillingPostalCode;
        this.quoteObj.QuoteToCountry = this.accountObj.BillingCountry;

        
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

            if (taxResponse != null && taxResponse.totalRate != null) {
                System.debug('new estimated tax rate set -> ' + taxResponse.totalRate);
                this.estimatedTaxRate = taxResponse.totalRate;
                this.taxRatePercentage = String.valueOf((this.estimatedTaxRate * 100).setScale(2)) + '%';
            }

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

		this.quoteObj.Tax = (this.currentTotalPrice * this.estimatedTaxRate).setScale(2);
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
        
        PageReference pageRef = Page.FinalizeQuoteAccount;
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public PageReference back(){
        
        PageReference pageRef = Page.QuoteAccount;
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public PageReference saveQuote(){
        
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        List<OpportunitylineItem> lineItemList = new List<OpportunityLineItem>();
        
        Set<Id> quoteIds = new Set<Id>();
        
        if (String.isBlank(this.quoteObj.Project2__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You must select an existing project or create a new project!'));
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        Opportunity opp =  new Opportunity(Name = 'created by quick action',
                                            CloseDate = Date.today().addDays(14), // should this be user input?
                                            Project__c = this.quoteObj.Project2__c,
                                            AccountId = this.accountObj.Id,
                                            StageName = 'Estimating');
        try {
               
            insert opp;
                
            this.quoteObj.OpportunityId = opp.Id;
                                   
        } catch(Exception e){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving Opportunity!'));
            return null;
        }

        Integer sortOrder = 0;
        // insert opportunity line items
        for (QuoteRow qr :this.quoteRows) {
            sortOrder++;
            lineItemList.add(new OpportunityLineItem(SortOrder = sortOrder,
                                                     Product2Id = qr.productId,
                                                     OpportunityId = opp.Id,
                                                     Quantity = qr.quantity, 
                                                     PricebookEntryId = qr.PricebookEntryId, 
                                                     UnitPrice = qr.unitPrice, 
                                                     Description = qr.specialNotes));   
        }
        
        try {
            
            insert lineItemList;
        
        } catch(Exception e){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving OpportunityLineItem!'));
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
		
		Integer qliSortOrder = 0;
        for (OpportunityLineItem oli :lineItemList) {
			qliSortOrder++;
            // String qliJson = '{"SortOrder": "'+sortOrder+'", "Product2Id": "'+qr.productId+'", "QuoteId": "'+this.quoteObj.Id+'", "Quantity": "'+qr.quantity+'", "PricebookEntryId": "'+qr.pricebookEntryId+'", "UnitPrice": "'+qr.unitPrice+'", "Description": "'+qr.specialNotes+'"}';
            // QuoteLineItem theQuoteLineItem = (QuoteLineItem) JSON.deserialize(qliJson, QuoteLineItem.class);
            quoteLineItemList.add(new QuoteLineItem (SortOrder = qliSortOrder,
													 Product2Id = oli.Product2Id,
                                                     QuoteId = this.quoteObj.Id,
                                                     Quantity = oli.Quantity, 
                                                     PricebookEntryId = oli.PricebookEntryId, 
                                                     UnitPrice = oli.UnitPrice, 
                                                     Description = oli.Description,
                                                     OpportunityLineItemId = oli.Id
                                                     ));
        }

        try {
            
            insert quoteLineItemList;
        
        } catch(Exception e){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Problem Saving QuoteLineItem!'));
            return null;
        }

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

        PageReference projPage = new ApexPages.StandardController(this.quoteObj).view();
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