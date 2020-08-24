public with sharing class SfsDataRetrieve {
    
    @AuraEnabled (cacheable=true)
    public static string getJson(){

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://raw.githubusercontent.com/StrategicFS/Recruitment/master/data.json');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(req);

        system.debug(response.getBody());

        return response.getBody();
        
    }
}