public with sharing class SfsDataRetrieve {
    
    @AuraEnabled (cacheable=true)
    public static string getJson(){

        HttpRequest req = new HttpRequest();

        External_Data_Sources__mdt sourceMdt = [select Source_URL__c from External_Data_Sources__mdt where DeveloperName = 'SFS_Creditor_Table'];

        req.setEndpoint(sourceMdt.Source_URL__c);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(req);

        system.debug(response.getBody());

        return response.getBody();
        
    }
}