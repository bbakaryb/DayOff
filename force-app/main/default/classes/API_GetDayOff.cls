global with sharing class API_GetDayOff {

    public static void doGetDaysOff(String zone, Integer year) {
        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:days_off_france/' + zone + '/' + year + '.json');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                System.debug('Unexpected status: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                // Send raw JSON to async handler
                UpdateCustomMetadata.asyncManageMetadata(zone, year, response.getBody());
            }
        } catch (Exception e) {
            System.debug('Erreur API: ' + e.getMessage());
        }
    }
}
