@IsTest
private class API_GetDayOff_TEST {

    // Simple success mock with dynamic holidays
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // Split the endpoint and get the last part manually
            String[] parts = req.getEndpoint().split('/');
            String yearStr = parts[parts.size() - 1].replace('.json','');
            Integer year = Integer.valueOf(yearStr);

            res.setBody('{ "'+ year +'-01-01": "Jour de l\'an", "'+ year +'-05-01": "Fête du Travail" }');
            return res;
        }
    }

    private class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    private static void assertFlowOutput(DateTime rdv, String expectedResponse, Integer expectedStatus, HttpCalloutMock mock) {
        if (mock != null) Test.setMock(HttpCalloutMock.class, mock);

        API_GetDayOff.FlowInput input = new API_GetDayOff.FlowInput();
        input.zone = 'metropole';
        input.rdv = rdv;

        Test.startTest();
        List<API_GetDayOff.FlowOutput> outputs = API_GetDayOff.doGetDaysOff(new List<API_GetDayOff.FlowInput>{ input });
        Test.stopTest();

        System.assertEquals(1, outputs.size());
        System.assertEquals(expectedStatus, outputs[0].StatusCode);
        System.assertEquals(expectedResponse, outputs[0].response);
    }

    @IsTest static void testHolidayDay() { assertFlowOutput(getHolidayDate(), 'Holiday', -1, new SuccessMock()); }
    @IsTest static void testWeekendDay() { assertFlowOutput(getWeekendDate(), 'Weekend', -1, new SuccessMock()); }
    @IsTest static void testNormalDay()  { assertFlowOutput(getNormalDate(), 'OK', 200, new SuccessMock()); }

    @IsTest static void testHttpError() {
        API_GetDayOff.FlowInput input = new API_GetDayOff.FlowInput();
        input.zone = 'test_error_zone';
        input.rdv = getNormalDate();

        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        List<API_GetDayOff.FlowOutput> outputs = API_GetDayOff.doGetDaysOff(new List<API_GetDayOff.FlowInput>{ input });
        Test.stopTest();

        System.assertEquals(1, outputs.size());
        System.assertEquals(500, outputs[0].StatusCode);
    }

    private static DateTime getDateTimeAvoidingWeekends(List<Date> candidates) {
        for (Date d : candidates) {
            Integer dow = Integer.valueOf(DateTime.newInstance(d, Time.newInstance(0,0,0,0)).format('u'));
            if (dow != 6 && dow != 7) return DateTime.newInstance(d.year(), d.month(), d.day(), 10, 0, 0);
        }
        // fallback to first candidate if all are weekends
        Date d = candidates[0];
        return DateTime.newInstance(d.year(), d.month(), d.day(), 10, 0, 0);
    }

    public static DateTime getHolidayDate() {
        Integer year = Date.today().year() + 3;
        return getDateTimeAvoidingWeekends(new List<Date>{
            Date.newInstance(year,1,1),
            Date.newInstance(year,5,1)
        });
    }

    public static DateTime getWeekendDate() {
        Date today = Date.today();
        Integer dow = Integer.valueOf(DateTime.newInstance(today, Time.newInstance(0,0,0,0)).format('u'));
        Integer daysToSaturday = 6 - dow; // Saturday = 6
        if (daysToSaturday < 0) daysToSaturday += 7; // if today is Sunday, go to next Saturday
        Date saturday = today.addDays(daysToSaturday);
        return DateTime.newInstance(saturday.year(), saturday.month(), saturday.day(), 10, 0, 0);
    }

    public static DateTime getNormalDate() {
        Date today = Date.today().addDays(1);
        Set<Date> fixedHolidays = new Set<Date>{Date.newInstance(today.year(),1,1), Date.newInstance(today.year(),5,1)};

        while (true) {
            Integer dow = Integer.valueOf(DateTime.newInstance(today, Time.newInstance(0,0,0,0)).format('u'));
            if (dow != 6 && dow != 7 && !fixedHolidays.contains(today)) break;
            today = today.addDays(1);
        }
        return DateTime.newInstance(today.year(), today.month(), today.day(), 10, 0, 0);
    }
}
