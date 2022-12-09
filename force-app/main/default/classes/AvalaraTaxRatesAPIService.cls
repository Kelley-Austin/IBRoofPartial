public class AvalaraTaxRatesAPIService {

    public static TaxResponse getTaxRates(String zipCode, String country) {
        return getTaxRates('https://sandbox-rest.avatax.com/api/v2/taxrates/bypostalcode?country=' + country + '&postalCode=' + zipCode);
    }

    public static TaxResponse getTaxRates(String endpoint) {
        HttpRequest req = new HttpRequest();
     	req.setEndpoint(endpoint);
     	req.setMethod('GET');
        req.setTimeout(120000);

        Avalara_Tax_API__c avalaraSettings = Avalara_Tax_API__c.getOrgDefaults();

        if (avalaraSettings.username__c == null || avalaraSettings.password__c == null) {
            system.debug('Missing credentials');
            return null;
        }

        Blob authValue = Blob.valueOf(avalaraSettings.username__c + ':' + avalaraSettings.password__c);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(authValue);
        req.setHeader('Authorization', authHeader);

        Http http = new Http();
     	HTTPResponse res = http.send(req);

        System.debug('getTaxRates response getStatusCode'+ res.getStatusCode());
        System.debug('getTaxRates response body'+ res.getBody());

        if (res.getStatusCode() != 200){
            throw new TaxRatesException(res.getStatusCode() +' '+ res.getBody());
        }

        TaxResponse payload = (TaxResponse) JSON.deserialize(res.getBody(), TaxResponse.class);

        return payload;
    }

    public class TaxResponse {
        public Decimal totalRate;
        public List<TaxRate> rates;
    }

    public class TaxRate {
        public Decimal rate;
        public String name;
        public String type;
    }

    public class TaxRatesException extends Exception {}
}