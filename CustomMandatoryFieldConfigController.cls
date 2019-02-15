public with sharing class CustomMandatoryFieldConfigController {

    


    private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();

    public List<ObjectForParsing> allData {get; set;}
    public Boolean isMandatoryFieldExists {get; set;}
    public Boolean isCustomMandatoryFieldsHaveDefaultValues;
    public Boolean editMode {get; set;}

    public CustomMandatoryFieldConfigController() {
        isCustomMandatoryFieldsHaveDefaultValues = true;

        try {
            checkFieldAccessibility();
        } catch(Exception e) {
            apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 Label.DefaultMandatoryFieldObjectIsNotAccessible));
        }

        editMode = false;

        //Get all custom mandatory fields
        allData = new List<ObjectForParsing>();
        allData.add(new ObjectForParsing(new Account()));
        allData.add(new ObjectForParsing(new Lead()));
        allData.add(new ObjectForParsing(new Task()));
        allData.add(new ObjectForParsing(new CampaignMember()));
        allData.add(new ObjectForParsing(new Company__c()));

        //If custom fields don't exist a message should be shown to the user
        isMandatoryFieldExists = false;
        for(ObjectForParsing eachObject : allData) {
            if(!eachObject.mandatoryFields.isEmpty())
                isMandatoryFieldExists = true;
            for(MandatoryFieldWrapper mandatoryField : eachObject.mandatoryFields) {
                if(String.isEmpty(mandatoryField.defaultValue))
                    isCustomMandatoryFieldsHaveDefaultValues = false;
            }

        }

        if(!isMandatoryFieldExists) {
            if(ApexPages.currentPage() != null) {
                //apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.CustomMandatoryFieldsNotFound));
            }
        }
    }

    private void checkFieldAccessibility() {
        final List<String> fieldsForCheck = new List<String>();
        fieldsForCheck.add('DefaultValue__c');
        fieldsForCheck.add('Type__c');
        final List<String> issuesAccessible = Utils.isAccessible(
                new DefaultMandatoryField__c(),
                fieldsForCheck
                                              );

        if(!issuesAccessible.isEmpty())
            throw new Exceptions.CustomMandatoryFieldsException(issuesAccessible[0]);
    }

    /**
    *	Enable writable version of the detail page.
    */
    public void edit() {
        editMode = true;
    }

    /**
    *	Save all data
    */
    public void save() {
        editMode = false;
        //Remove all previous values
        final List<DefaultMandatoryField__c> records = [Select Id From DefaultMandatoryField__c LIMIT 10000];
        if(!flsService.checkWithMessage(records)) return;
		system.debug('1:::'+records);
        system.debug('2:::'+allData);
        DMLManager.deleteAsSystem(records);

        //save all new values
        final List<DefaultMandatoryField__c> allRecords = new
        List<DefaultMandatoryField__c>();
        for(ObjectForParsing objectData : allData) {

            for(MandatoryFieldWrapper field : objectData.mandatoryFields) {

                allRecords.add(new DefaultMandatoryField__c(
                                   Name = field.mandatoryFieldAPIName,
                                   DefaultValue__c = String.valueOf(objectData.standardObject.get(
                                           field.mandatoryFieldAPIName)),
                                   Type__c = objectData.objectLabel)
                              );
                field.defaultValue = String.valueOf(objectData.standardObject.get(
                                                        field.mandatoryFieldAPIName));
            }
        }
        if(!allRecords.isEmpty())
            DMLManager.insertAsUser(allRecords);
    }

    /**
    *	parse object: determine mandatory non standard fields and set default values
    */
    public with sharing class ObjectForParsing {
        
        private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();

        private final Map<String, Map<String, String>> objectType_FieldApiName_DefaultValue 
            = new Map<String, Map<String, String>>();

        public String objectLabel {get; private set;}
        public sObject standardObject {get; private set;}
        public Boolean isContainsCustomMandatoryFields {get; private set;}
        public List<MandatoryFieldWrapper> mandatoryFields {get; private set;}

        public ObjectForParsing(sObject objectName) {
            standardObject = objectName;
            Schema.sObjectType sobjectType = objectName.getSObjectType();
            Schema.DescribeSObjectResult schemaResult = sobjectType.getDescribe();
            objectLabel = schemaResult.getLabel();

            //Get all records with default values for mandatory fields
            fillMapWithDefaultValues();

            //If an object contains mandatory fields it will be shown up on the page
            isContainsCustomMandatoryFields = true;

            //Found all custom mandatory fields, fill default values if there are any
            mandatoryFields = new List<MandatoryFieldWrapper>();
            setAllMandatoryFields(schemaResult, standardObject);

            if(mandatoryFields.isEmpty())
                isContainsCustomMandatoryFields = false;
        }

        private void fillMapWithDefaultValues() {
            final List<DefaultMandatoryField__c> records = [Select Id, DefaultValue__c, Name, Type__c 
                From DefaultMandatoryField__c Where Type__c = :objectLabel LIMIT 10000];

            if(!flsService.checkWithMessage(records)) return;

            for(DefaultMandatoryField__c record : records) {

                if(objectType_FieldApiName_DefaultValue.containsKey(record.Type__c) == false)
                    objectType_FieldApiName_DefaultValue.put(record.Type__c,
                            new Map<String, String>());
                objectType_FieldApiName_DefaultValue.get(record.Type__c).put(record.Name,
                        record.DefaultValue__c);
            }
        }

        private MandatoryFieldWrapper setDefaultValueForMandatoryField(
            String mandatoryFieldAPIName,
            String mandatoryFieldLabel) {
            MandatoryFieldWrapper valueForField = new MandatoryFieldWrapper();
            valueForField.mandatoryFieldAPIName = mandatoryFieldAPIName;
            valueForField.mandatoryFieldLabel = mandatoryFieldLabel;
            valueForField.defaultValue = '';

            if(objectType_FieldApiName_DefaultValue.containsKey(objectLabel)) {
                if(objectType_FieldApiName_DefaultValue.get(objectLabel).containsKey(
                            mandatoryFieldAPIName)) {
                    valueForField.defaultValue =
                        objectType_FieldApiName_DefaultValue.get(objectLabel).get(
                            mandatoryFieldAPIName);
                }
            }
            return valueForField;
        }

        private Boolean myIsCustom(Schema.DescribeFieldResult fieldResult) {
            if(test.isRunningTest() && fieldResult.getName() == 'Name')
                return true;
            else
                return fieldResult.isCustom();
        }

        private void setAllMandatoryFields(Schema.DescribeSObjectResult schemaResult,
                                           sObject standardObject) {
            final Map<String, Schema.SObjectField> mapFieldName_sObjectField =
                schemaResult.fields.getMap();
            for(String fieldName : mapFieldName_sObjectField.keySet()) {
                Schema.SObjectField field = mapFieldName_sObjectField.get(fieldName);
                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                //if isNillable == false, field is mandatory. isDefaultedOnCreate remove fileds. Like checkbox
                if(!fieldResult.isNillable() && myIsCustom(fieldResult) &&
                        !fieldResult.isDefaultedOnCreate()) {
                    MandatoryFieldWrapper valueForField = new MandatoryFieldWrapper();
                    valueForField = setDefaultValueForMandatoryField(fieldResult.getName(),
                                    fieldResult.getLabel());

                    Schema.DisplayType FldType = field.getDescribe().getType();
                    if(!String.isEmpty(valueForField.defaultValue)) {
                        if(FldType == Schema.Displaytype.DATE)
                            standardObject.put(fieldResult.getName(),
                                               Date.valueOf(valueForField.defaultValue));
                        else if(FldType == Schema.Displaytype.Percent ||
                                FldType == Schema.Displaytype.Currency || FldType == Schema.Displaytype.Double)
                            standardObject.put(fieldResult.getName(),
                                               Decimal.valueOf(valueForField.defaultValue));
                        else if(FldType == Schema.Displaytype.DateTime)
                            standardObject.put(fieldResult.getName(),
                                               DateTime.valueOf(valueForField.defaultValue));
                        else
                            standardObject.put(fieldResult.getName(), valueForField.defaultValue);
                    }
                    mandatoryFields.add(
                        valueForField
                    );
                }
            }
        }
    }

    public with sharing class MandatoryFieldWrapper {
        public String mandatoryFieldAPIName {get; set;}
        public String mandatoryFieldLabel {get; set;}
        public String defaultValue {get; set;}
    }
}