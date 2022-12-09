public class pdfopeninvoicecntrl {
    
	public ID OrderID=apexpages.currentpage().getparameters().get('id');
    public List<Open_Invoice_Details__c> opiList{get;set;}
    //Open_Invoice__c
    public ID conId=apexpages.currentPage().getparameters().get('id');
    
    public pdfopeninvoicecntrl(ApexPages.StandardController stdController){
       opiList = [SELECT Id, Name, Open_Invoice__c, Open_Invoice_Detail__c, Item_Code__c, Item_Description__c, Quantity_Shipped__c, Quantity_Ordered__c, Quantity_BackOrdered__c, Unit_Price__c, Extended_Price__c FROM Open_Invoice_Details__c  Where Open_Invoice__c =: stdController.getId()];
    }    
}