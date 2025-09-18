public without sharing class UpdateCustomMetadata {

    @future
    public static void asyncManageMetadata(String zone, Integer year, String holidaysJson) {

        Map<String, Object> joursFeries = (Map<String, Object>) JSON.deserializeUntyped(holidaysJson);

        String recordName = zone + '_' + year;
        recordName = recordName.replaceAll('-', '_');
        recordName = recordName.replaceAll('__', '_');

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

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.No_Working_Day__mdt.fields.getMap();
        Map<String, String> labelToApiName = new Map<String, String>();

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            labelToApiName.put(dfr.getLabel(), fieldName);
        }

        for (String dateStr : joursFeries.keySet()) {
            String label = (String) joursFeries.get(dateStr);
            Date dateValue;

            try {
                dateValue = Date.valueOf(dateStr);
            } catch (Exception e) {
                continue; 
            }

            // check if api data label match custom metadata field label
            if (labelToApiName.containsKey(label)) {
                addValue(cmd, labelToApiName.get(label), dateValue);
            } else {
                System.debug('Any field match for label : ' + label);
            }
        }

        // Deployment metadata
        Metadata.DeployContainer dc = new Metadata.DeployContainer();
        dc.addMetadata(cmd);

        if (!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(dc, new CustomMetadataCallback());
            System.debug('Deployment jobId: ' + jobId);
        }
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
