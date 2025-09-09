public without sharing class UpdateCustomMetadata {

    @future
    public static void asyncManageMetadata(String zone, Integer year, String holidaysJson) {

        Map<String, Object> joursFeries = (Map<String, Object>) JSON.deserializeUntyped(holidaysJson);

        String recordName = zone + '_' + year;

        Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();
        cmd.fullName = 'No_Working_Day__mdt.' + recordName;
        cmd.label    = recordName;

        Metadata.CustomMetadataValue zoneVal = new Metadata.CustomMetadataValue();
        zoneVal.field = 'zone__c';
        zoneVal.value = zone;
        cmd.values.add(zoneVal);

        Metadata.CustomMetadataValue nameVal = new Metadata.CustomMetadataValue();
        nameVal.field = 'Name__c';
        nameVal.value = recordName;
        cmd.values.add(nameVal);

        // Map each holiday to the correct field
        for (String dateStr : joursFeries.keySet()) {
            String label = (String) joursFeries.get(dateStr);
            Date dateValue;
            try {
                dateValue = Date.valueOf(dateStr);
            } catch (Exception e) {
                continue;
            }

            if (label.contains('janvier'))        addValue(cmd, 'X1er_janvier__c', dateValue);
            else if (label.contains('Pâques'))    addValue(cmd, 'Lundi_Paques__c', dateValue);
            else if (label.contains('1er mai'))   addValue(cmd, 'X1er_mai__c', dateValue);
            else if (label.contains('8 mai'))     addValue(cmd, 'X8_mai__c', dateValue);
            else if (label.contains('Ascension')) addValue(cmd, 'Ascension__c', dateValue);
            else if (label.contains('Pentecôte')) addValue(cmd, 'Lundi_Pentecote__c', dateValue);
            else if (label.contains('juillet'))   addValue(cmd, 'X14_juillet__c', dateValue);
            else if (label.contains('Assomption')) addValue(cmd, 'Assomption__c', dateValue);
            else if (label.contains('Toussaint')) addValue(cmd, 'Toussaint__c', dateValue);
            else if (label.contains('novembre'))  addValue(cmd, 'X11_novembre__c', dateValue);
            else if (label.contains('Noël'))      addValue(cmd, 'Jour_Noel__c', dateValue);
        }

        Metadata.DeployContainer dc = new Metadata.DeployContainer();
        dc.addMetadata(cmd);

        Id jobId = Metadata.Operations.enqueueDeployment(dc, new CustomMetadataCallback());
        System.debug('Deployment jobId: ' + jobId);
    }

    private static void addValue(Metadata.CustomMetadata cmd, String field, Date value) {
        Metadata.CustomMetadataValue v = new Metadata.CustomMetadataValue();
        v.field = field;
        v.value = value;
        cmd.values.add(v);
    }

    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            if (result.status == Metadata.DeployStatus.Succeeded) {
                System.debug('Custom Metadata create/update');
            } else {
                System.debug('Error: ' + result.errorMessage);
            }
        }
    }
}
