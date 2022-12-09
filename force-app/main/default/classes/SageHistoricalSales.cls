@RestResource(urlMapping='/sageHistoricalSales/*')
global class SageHistoricalSales {
    public SageHistoricalSales() {

    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        List<ResponseItem> resBody = new List<ResponseItem>();

        

        List<Historical_Sales__c> upsertList = new List<Historical_Sales__c>();


        RequestBody body;

        system.debug('req.requestBody.toString() -> '+ req.requestBody.toString());

        
        try {
            body = (RequestBody) JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        } catch (Exception e) {
            System.debug(e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(e.getMessage());
            return;
        }
        
        for (Record rec :body.records){
            system.debug(rec);

            upsertList.add(rec.toSobject());
        }


        // upsert or select with for update ???

        List<Database.upsertResult> upsertResults = Database.upsert(upsertList, Historical_Sales__c.fields.External_Id__c, false);

        for (Integer i = 0; i < upsertResults.size(); i++) {
            resBody.add(new ResponseItem(upsertResults.get(i).getId(), upsertResults.get(i).isSuccess(), upsertResults.get(i).getErrors(), upsertList.get(i)));
        }

        // no server errors return 200
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(resBody));
    }

    public class RequestBody {
        public Boolean allOrNone;
	    public List<Record> records;
    }
    public class Attribute {
		public String type;
	}
    public class Record {

        public Attribute attributes;
        public String ExternalId;
        public String ARDivisionNo;
        public String CustomerNo;
        public String InvoiceDate;
        public String InvoiceNo;
        public Decimal TaxableSalesAmt;
        public Decimal NonTaxableSalesAmt;
        public String CustomerPONo;
        public Decimal FreightAmt;
        public String InvoiceDueDate;
        public Decimal UDF_IB_FREIGHT;
        public String OrderDate;
        public String SalesOrderNo;
        public String SalespersonNo;
        public Decimal SalesTaxAmt;
        public String ShipDate;
        public String ShipVia;
        public String TermsCode;
        public String HeaderSeqNo;

        public Historical_Sales__c toSobject(){
            Historical_Sales__c hs = new Historical_Sales__c();
            hs.External_Id__c = this.ExternalId;

            hs.ARDivisionNo__c = this.ARDivisionNo;
            hs.CustomerNo__c = this.CustomerNo;
            hs.InvoiceDate__c = this.InvoiceDate;
            hs.Invoice_Number__c = this.InvoiceNo;
            hs.TaxableSalesAmt__c = this.TaxableSalesAmt;
            hs.NonTaxableSalesAmt__c = this.NonTaxableSalesAmt;
            hs.Name = this.InvoiceNo;
            hs.Customer_PO_Number__c = this.CustomerPONo;
            hs.Freight_Amount__c = this.FreightAmt;
            hs.InvoiceDueDate__c = this.InvoiceDueDate;
            hs.Less_Freight_Discount__c = this.UDF_IB_FREIGHT;
            hs.OrderDate__c = this.OrderDate;
            hs.Order_Number__c = this.SalesOrderNo;
            hs.Rep__c = this.SalespersonNo;
            hs.Sales_Tax__c = this.SalesTaxAmt;
            hs.ShipDate__c = this.ShipDate;
            hs.Ship_Via__c = this.ShipVia;
            hs.TermsCode__c = this.TermsCode;
            hs.HeaderSeqNo__c = this.HeaderSeqNo;



            return hs;
        }
    }
    /*
    'External_Id__c': self.historicalSaleUuid,
            'ARDivisionNo__c': self.ARDivisionNo,
            'CustomerNo__c': self.CustomerNo,
            'InvoiceDate__c': self.InvoiceDate,
            'Invoice_Number__c': self.InvoiceNo,
            'TaxableSalesAmt__c': self.TaxableSalesAmt,
            'NonTaxableSalesAmt__c': self.NonTaxableSalesAmt,
            'Name': self.InvoiceNo,
            'Customer_PO_Number__c': self.CustomerPONo,
            'Freight_Amount__c': self.FreightAmt,
            'InvoiceDueDate__c': self.InvoiceDueDate,
            'Less_Freight_Discount__c': self.UDF_IB_FREIGHT,
            'OrderDate__c': self.OrderDate,
            'Order_Number__c': self.SalesOrderNo,
            'Rep__c': self.SalespersonNo,
            'Sales_Tax__c': self.SalesTaxAmt,
            'ShipDate__c': self.ShipDate,
            'Ship_Via__c': self.ShipVia,
            'TermsCode__c': self.TermsCode,
            'HeaderSeqNo__c': self.HeaderSeqNo
    */

    public class ResponseItem {
        public String id;
        public Boolean success;
        public List<Database.Error> errors;
        public Historical_Sales__c hs;

        public ResponseItem(String id, Boolean success, List<Database.Error> errors, Historical_Sales__c hs) {
            this.id = id;
            this.success = success;
            this.errors = errors;
            this.hs = hs;
        }
    }


}