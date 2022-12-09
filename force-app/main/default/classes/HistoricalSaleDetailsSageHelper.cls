public class HistoricalSaleDetailsSageHelper {
    private List<Historical_Sale_Details__c> oldList;
    private List<Historical_Sale_Details__c> newList;
    
    public HistoricalSaleDetailsSageHelper(List<Historical_Sale_Details__c> oldList, List<Historical_Sale_Details__c> newList) {
    	this.oldList = (oldList == null) ? new List<Historical_Sale_Details__c>() : oldList;
    	this.newList = (newList == null) ? new List<Historical_Sale_Details__c>() : newList;
    }

    public void execute() {
        Set<String> historicalSaleExtIds = new Set<String>();

        for (Historical_Sale_Details__c historicalSaleDetail : this.newList) {
            if (String.isBlank(historicalSaleDetail.InvoiceNo__c))
                continue;

            if (String.isBlank(historicalSaleDetail.HeaderSeqNo__c))
                continue;

            historicalSaleExtIds.add(String.valueOf(historicalSaleDetail.InvoiceNo__c).leftPad(7, '0') + '-' + historicalSaleDetail.HeaderSeqNo__c);
        }

        List<Historical_Sales__c> historicalSales = [SELECT Id, External_Id__c FROM Historical_Sales__c WHERE External_Id__c IN :historicalSaleExtIds];
        Map<String,Historical_Sales__c> historicalSaleByExtId = new Map<String,Historical_Sales__c>();

        for (Historical_Sales__c historicalSale : historicalSales) {
            historicalSaleByExtId.put(historicalSale.External_Id__c, historicalSale);
        }
        
        for (Historical_Sale_Details__c historicalSaleDetail : this.newList) {
            if (String.isBlank(historicalSaleDetail.InvoiceNo__c))
                continue;

            if (String.isBlank(historicalSaleDetail.HeaderSeqNo__c))
                continue;

            Historical_Sales__c historicalSale = historicalSaleByExtId.get(String.valueOf(historicalSaleDetail.InvoiceNo__c).leftPad(7, '0') + '-' + historicalSaleDetail.HeaderSeqNo__c);

            if (historicalSale == null)
                continue;

            if (historicalSaleDetail.Historical_Sales__c == historicalSale.Id)
                continue;

            historicalSaleDetail.Historical_Sales__c = historicalSale.Id;
        }
    }
}