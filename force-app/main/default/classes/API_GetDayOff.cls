global with sharing class API_GetDayOff {

    @invocableMethod(callout=true label='GET France Holidays')
    public static List<FlowOutput> doGetDaysOff(List<FlowInput> params) {

        List<FlowOutput> outputs = new List<FlowOutput>(); 
        FlowOutput output = new FlowOutput(); 
        FlowInput param = params.get(0);
        DateTime tmp = param.rdv;
        Date dateRDV = tmp.date();
        Integer year = dateRDV.year();

        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:days_off_france/' + param.zone + '/' + year + '.json');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Boolean dayOfWeek = isWeekend(dateRDV);

        if(dayOfWeek) {
            output.StatusCode = -1; 
            output.response = 'Weekend';
            outputs.add(output);
            return outputs;
        }
        String recordName = param.zone + '_' + year;
        List<No_Working_Day__mdt> holidayMetadata = [
                                                       SELECT 
                                                            Name__c,
                                                            zone__c,
                                                            X1er_janvier__c,
                                                            Lundi_Paques__c,
                                                            X1er_mai__c,
                                                            X8_mai__c,
                                                            Ascension__c,
                                                            Lundi_Pentecote__c,
                                                            X14_juillet__c,
                                                            Assomption__c,
                                                            Toussaint__c,
                                                            X11_novembre__c,
                                                            Jour_Noel__c,
                                                            Vendredi_saint__c,
                                                            Abolition_Esclavage__c,
                                                            X2eme_jour_Noel__c
                                                        FROM No_Working_Day__mdt 
                                                        WHERE Name__c = :recordName
                                                    ];
        if(holidayMetadata.isEmpty()) {
                try {
                    HttpResponse response = http.send(request);
                    if (response.getStatusCode() != 200) {
                        output.StatusCode = response.getStatusCode(); 
                        output.response = 'Error ' + response.getStatusCode() + ' ' + response.getStatus();
                    } else {
                        // Send raw JSON to async handler
                        UpdateCustomMetadata.asyncManageMetadata(param.zone, year, response.getBody());
                        Map<String, Object> holidays = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        if (isHoliday(dateRDV, holidays)) {
                            output.StatusCode = -1;
                            output.response   = 'Holiday';
                        } else {
                            output.StatusCode = 200; 
                            output.response = 'OK';
                        }
                    }
                } catch (Exception e) {
                    output.StatusCode = -1; 
                    output.response = 'Error API: ' + e.getMessage();
                }
        } else { 
            Boolean isHoliday = isHolidayMetadata(dateRDV, holidayMetadata.get(0));
            if(isHoliday) {
                output.StatusCode = -1; 
                output.response = 'Holiday';
            } else {
                output.StatusCode = 200; 
                output.response = 'OK';
            }
        }
        outputs.add(output);
        return outputs;
    }

    public static Boolean isHoliday(Date tmp, Map<String, Object> holidays) {
        for (String dateStr : holidays.keySet()) {
            Date holidayDate;
            try {
                holidayDate = Date.valueOf(dateStr);
            } catch (Exception e) {
                continue;
            }
            if (holidayDate == tmp) return true;
        }
        return false;
    }

    public static Boolean isHolidayMetadata(Date tmp, No_Working_Day__mdt rec) {
        Set<Date> holidays = new Set<Date>();
        if (rec.X1er_janvier__c       != null) holidays.add(rec.X1er_janvier__c);
        if (rec.Lundi_Paques__c       != null) holidays.add(rec.Lundi_Paques__c);
        if (rec.X1er_mai__c           != null) holidays.add(rec.X1er_mai__c);
        if (rec.X8_mai__c             != null) holidays.add(rec.X8_mai__c);
        if (rec.Ascension__c          != null) holidays.add(rec.Ascension__c);
        if (rec.Lundi_Pentecote__c    != null) holidays.add(rec.Lundi_Pentecote__c);
        if (rec.X14_juillet__c        != null) holidays.add(rec.X14_juillet__c);
        if (rec.Assomption__c         != null) holidays.add(rec.Assomption__c);
        if (rec.Toussaint__c          != null) holidays.add(rec.Toussaint__c);
        if (rec.X11_novembre__c       != null) holidays.add(rec.X11_novembre__c);
        if (rec.Jour_Noel__c          != null) holidays.add(rec.Jour_Noel__c);
        if (rec.Vendredi_saint__c     != null) holidays.add(rec.Vendredi_saint__c);
        if (rec.Abolition_Esclavage__c!= null) holidays.add(rec.Abolition_Esclavage__c);
        if (rec.X2eme_jour_Noel__c    != null) holidays.add(rec.X2eme_jour_Noel__c);
        return holidays.contains(tmp);
    }

    public static Boolean isWeekend(Date tmp) {
        Integer dayOfWeek = Integer.valueOf(DateTime.newInstance(tmp, Time.newInstance(0,0,0,0)).format('u'));
        return dayOfWeek == 6 || dayOfWeek == 7; // 6 = saturday, 7 = sunday
    }

    public class FlowInput { 
        @invocableVariable public String zone; 
        @invocableVariable public DateTime rdv; 
    } 
    
    public class FlowOutput { 
        @InvocableVariable public Integer StatusCode; 
        @InvocableVariable public String response; 
    }

}
