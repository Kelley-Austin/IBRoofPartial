@isTest
global class MockDeviceMagicResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
    	
    	HttpResponse res = new HttpResponse();
	    res.setHeader('Content-Type', 'application/json');
	    res.setBody('{"example":"test"}');
	    res.setStatusCode(200);
	    
    	if( req.getEndpoint().contains('/devices.json')) {
    		res.setBody('{"devices":[{"id":123,"identifier":"test"}]}');
    	} else if (req.getEndpoint().contains('/forms.json')) {
    		res.setBody('{"forms":[{"id":123,"namespace":"test","name":"testform"}]}');
    	} else if (req.getEndpoint().contains('/oneshots')) {
    		res.setStatusCode(202);
    	} 
    	
    	
	    return res;
    }
    
}