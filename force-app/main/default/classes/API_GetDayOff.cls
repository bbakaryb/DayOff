global with sharing class API_GetDayOff {

    global static String doGetDaysOff(String zone, Integer year) {
        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:days_off_france/' + zone + '/' + year + '.json');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        } catch (Exception e) {
            return e.getMessage().toString();
        }


        return null;
    }
    
    private class DayOff {
      
        public String X11_novembre__c;
        public String X14_juillet__c;
        public String X1er_janvier__c;
        public String X1er_mai__c;
        public String X8_mai__c;
        public String Ascension__c;
        public String Assomption__c;
        public String Jour_Noel__c;
        public String Lundi_Paques__c;
        public String Lundi_Pentecote__c;
        public String Toussaint__c;
        public String zone__c;
        public String Name__c;
    }
}