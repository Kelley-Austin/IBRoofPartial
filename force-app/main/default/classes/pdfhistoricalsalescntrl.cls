public class pdfhistoricalsalescntrl {
    public List<Historical_Sale_Details__c> hsdList{get;set;}
	public ID OrderID=apexpages.currentpage().getparameters().get('id');
    public ID conId=apexpages.currentPage().getparameters().get('id');
    public pdfhistoricalsalescntrl(ApexPages.StandardController stdController){
        hsdList = [SELECT Id, Name, Historical_Sales__c, Invoice_Order_Detail__c, Quantity_Ordered__c, Quantity_Shipped__c, Quantity_BackOrdered__c, Unit_Price__c, Extended_Price__c, Item_Code__c, Item_Description__c FROM Historical_Sale_Details__c where Historical_Sales__c =: stdController.getId()];
     }
}