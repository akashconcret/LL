public with sharing class CustomMandatoryFieldManager {
	
	private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();

	public static Boolean allDefaultFieldsConfigured() {
		final CustomMandatoryFieldManager fieldManager = new CustomMandatoryFieldManager();

		final List<SObject> sObjectsToCheck = new List<SObject> {
			new Lead(), new Task(), new Account(), new CampaignMember(), new Company__c()
		};

		Boolean result = true;
		for(SObject sObj : sObjectsToCheck) 
			result &= fieldManager.isAllMandatoryFieldsHaveDefaultValue(sObj);

		return result;
	}

	private Map<String, Map<String, String>> defaultValues;
	
	/**
	*	Methods for filling default values of mandatory fields
	*	For example from Trigger on update or insert
	*/

	public void fillMandatoryFieldsIfEmpty(List<sObject> records) {
	    system.debug('mandatory::'+records);
		Schema.sObjectType sobjectType = records[0].getSObjectType();
		Schema.DescribeSObjectResult schemaResult = sobjectType.getDescribe();

		String objectLabel = schemaResult.getLabel();
		//Get mandatory fields for incoming object
		final Set<String> mandatoryFields = getMandatoryFields(schemaResult);
		system.debug('mandatoryFields::'+mandatoryFields);
		if (mandatoryFields.isEmpty()) {
			return;
		}
		//set Default Values
		setDefaultValues(objectLabel);
		//if (!defaultValues.containsKey(schemaResult.getLabel())) {

		//	throw new Exceptions.CustomMandatoryFieldsException(
		//								Label.NoDefaultValuesForObject+' '+objectLabel
		//								);
		//}
		
		for (sObject record : records) {
			for (String mandatoryField : mandatoryFields) {

				final Object value = record.get(mandatoryField);
				if(value != null && String.isNotEmpty(String.valueOf(value))) continue;

				if (!defaultValues.isEmpty() && defaultValues.containsKey(objectLabel) && !defaultValues.get(objectLabel).containsKey(mandatoryField)) {
				// 	throw new Exceptions.CustomMandatoryFieldsException(
				// 									Label.NoDefaultValuesForField+' '+mandatoryField
				// 						);
				} else {
					if (record.get(mandatoryField) == null && !defaultValues.isEmpty() && defaultValues.containsKey(objectLabel) && defaultValues.get(objectLabel).containsKey(mandatoryField)) {
					    system.debug('defaultValues::'+defaultValues.isEmpty());
						Schema.SObjectField field;
						Schema.DisplayType FldType;

						for (Schema.SObjectField sField : schemaResult.fields.getMap().values()) {
							if (sField.getDescribe().getName() == mandatoryField) {
								field = sField;
								FldType = field.getDescribe().getType();
							}
						}

						if (FldType == Schema.Displaytype.DATE) {
							record.put(mandatoryField, Date.valueOf(defaultValues.get(objectLabel).get(mandatoryField)));
						} else if (FldType == Schema.Displaytype.Percent || FldType == Schema.Displaytype.Currency || FldType == Schema.Displaytype.Double){
							record.put(mandatoryField, Decimal.valueOf(defaultValues.get(objectLabel).get(mandatoryField)));
						} else if (FldType == Schema.Displaytype.DateTime){
							record.put(mandatoryField, DateTime.valueOf(defaultValues.get(objectLabel).get(mandatoryField)));
						} else {
							record.put(mandatoryField, defaultValues.get(objectLabel).get(mandatoryField));
						}
					} 
				}
			}
		}
	}
	
	/**
	*	Method for validate is all mandatory fields have default value
	*	@return: if no mandatory fields return true, if exist mandatory fields and default values is set return true else return false 
	*/
	public Boolean isAllMandatoryFieldsHaveDefaultValue(sObject record) {
		Schema.sObjectType sobjectType = record.getSObjectType();
		Schema.DescribeSObjectResult schemaResult = sobjectType.getDescribe();
		String objectLabel = schemaResult.getLabel();
		final Set<String> allIncomingMandatoryNames = getMandatoryFields(schemaResult);
		if (allIncomingMandatoryNames.isEmpty()) {
			return true;
		}
		try {
			setDefaultValues(objectLabel);
		} catch (Exception e) {
            system.debug('error ::');
			return false;
		}
		if (defaultValues != null && defaultValues.containsKey(objectLabel) == true) {
			for (String mandatoryFieldName : allIncomingMandatoryNames) {
				if(defaultValues.get(objectLabel).containsKey(mandatoryFieldName)) {
					if (String.isEmpty(defaultValues.get(objectLabel).get(mandatoryFieldName))) {
						return false;
					}
				} else {
					return false;
				}
			}
		} else {
			return false;
		} 
		return true;
	}
	
	private void setDefaultValues(String objectType) {
		if (defaultValues == null) {
			defaultValues = new Map<String, Map<String, String>>();
		}
		
		if (defaultValues.containsKey(objectType)) {
			return;
		} 
		List<DefaultMandatoryField__c> listDefaultValues = [Select 
																		Name, 
																		DefaultValue__c, 
																		Type__c 
																	From 
																		DefaultMandatoryField__c 
																	Where 
																		Type__c =:objectType];
																		
		system.debug('listDefaultValues::'+listDefaultValues);																

 		flsService.checkWithException(listDefaultValues);
 		
		if (!listDefaultValues.isEmpty()) {
			for (DefaultMandatoryField__c defaultValue : listDefaultValues) {
				if(!defaultValues.containsKey(objectType)) {
					defaultValues.put(objectType, new Map<String, String>());
				}
				if(defaultValue.Name != null && defaultValue.DefaultValue__c != null){
				    defaultValues.get(objectType).put(defaultValue.Name, defaultValue.DefaultValue__c);
				}
			}
		} else {
			//throw new Exceptions.CustomMandatoryFieldsException(Label.NoDefaultValuesForObject+' '+objectType);
		}
	}	 

	private Set<String> getMandatoryFields(Schema.DescribeSObjectResult schemaResult) {
		final Set<String> mandatoryFieldsApiName = new Set<String>();
        final Map<String,Schema.SObjectField> mapFieldName_sObjectField = schemaResult.fields.getMap();
        for(String fieldName : mapFieldName_sObjectField.keySet()) { 
            Schema.SObjectField field = mapFieldName_sObjectField.get(fieldName);
            Schema.DescribeFieldResult fieldResult = field.getDescribe();

            //Skip this field if it's not accessible - controllers should handle this 
            if(!fieldResult.isAccessible()) continue;

            //if isNillable == false, field is mandatory. isDefaultedOnCreate remove fileds. Like checkbox
            if (!fieldResult.isNillable() && fieldResult.isCustom() && !fieldResult.isDefaultedOnCreate() ) {
            	mandatoryFieldsApiName.add(fieldResult.getName());
            }
		}
		return mandatoryFieldsApiName;
	}	
}