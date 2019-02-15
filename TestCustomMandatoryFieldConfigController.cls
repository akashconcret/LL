@isTest
private class TestCustomMandatoryFieldConfigController {
    static testMethod void testCustomMandatoryFieldConfigController_testSaveDefaultValue() {
    	PageReference pageRef = Page.CustomMandatoryFieldConfiguration;
    	test.setCurrentPage(pageRef);
        // SettingsController ctrl = new SettingsController();
        CustomMandatoryFieldConfigController controller = new CustomMandatoryFieldConfigController();
        
        //check default values is empty
        system.assert([Select Id from DefaultMandatoryField__c].isEmpty());
        
        //Save value for Account.Name
		for (CustomMandatoryFieldConfigController.ObjectForParsing objectData : controller.allData) {
			for (CustomMandatoryFieldConfigController.MandatoryFieldWrapper field : objectData.mandatoryFields) {
				if (objectData.objectLabel == 'Account') {
					if (field.mandatoryFieldAPIName == 'Name') {
						field.mandatoryFieldAPIName = 'Name';
						field.defaultValue = 'Test Name';
					}
				}
			}
		}
		 
		controller.edit();
		controller.save();
		
		system.assert(![Select Id From DefaultMandatoryField__c].isEmpty());
		system.assert([Select 
							Id 
						From 
							DefaultMandatoryField__c 
						Where 
							Type__c = 'Account' And 
							Name='Name' And 
							DefaultValue__c = 'Test Name'].isEmpty());
    }
    
    static testMethod void testCustomMandatoryFieldConfigController_testEditDefaultValue() {
    	PageReference pageRef = Page.CustomMandatoryFieldConfiguration;
    	test.setCurrentPage(pageRef);
        // SettingsController ctrl = new SettingsController();
        CustomMandatoryFieldConfigController controller = new CustomMandatoryFieldConfigController();
        
        //check default values is empty
        system.assert([Select Id from DefaultMandatoryField__c].isEmpty());
        
        //Save value for Account.Name
		for (CustomMandatoryFieldConfigController.ObjectForParsing objectData : controller.allData) {
			for (CustomMandatoryFieldConfigController.MandatoryFieldWrapper field : objectData.mandatoryFields) {
				if (objectData.objectLabel == 'Account') {
					if (field.mandatoryFieldAPIName == 'Name') {
						field.mandatoryFieldAPIName = 'Name';
						field.defaultValue = 'Test Name';
					}
				}
			}
		}
		
		controller.edit();
		controller.save();
		
		system.assert(![Select Id from DefaultMandatoryField__c].isEmpty());
		system.assert([Select 
							Id 
						From 
							DefaultMandatoryField__c 
						Where 
							Type__c = 'Account' And 
							Name='Name' And 
							DefaultValue__c = 'Test Name'].isEmpty());
		
		CustomMandatoryFieldConfigController controller2 = new CustomMandatoryFieldConfigController();
		
		system.assert(![Select Id from DefaultMandatoryField__c].isEmpty());
		
		for (CustomMandatoryFieldConfigController.ObjectForParsing objectData : controller2.allData) {
			for (CustomMandatoryFieldConfigController.MandatoryFieldWrapper field : objectData.mandatoryFields) {
				if (objectData.objectLabel == 'Account') {
					if (field.mandatoryFieldAPIName == 'Name') {
						field.mandatoryFieldAPIName = 'Name';
						field.defaultValue = 'Test Name2';
					}
				}
			}
		}		
		controller2.edit();
		controller2.save();
		system.assert([Select 
							Id 
						from 
							DefaultMandatoryField__c 
						Where 
							Type__c = 'Account' And 
							Name='Name' And 
							DefaultValue__c = 'Test Name2'].isEmpty());
    }    
    
    
	static testMethod void testFillMandatoryFieldsIfEmpty_exceptionForNoDefaultValue() {
		system.assert([Select Id from DefaultMandatoryField__c].isEmpty());
		
		List<Account> newTestAccountReocrds = new List<Account>();
		newTestAccountReocrds.add(new Account()); 
		
		try {
			CustomMandatoryFieldManager fieldManager = new CustomMandatoryFieldManager(); 
			fieldManager.fillMandatoryFieldsIfEmpty(newTestAccountReocrds);
		} catch (Exception e) {
			
			system.assert(newTestAccountReocrds[0].Name == null);
			system.assert(true); 
		}
		
    }

    static testMethod void testFillMandatoryFieldsIfEmpty_theNameFieldIsFilledDefaultValue() {
    	
    	Schema.DescribeFieldResult dfr = Schema.sObjectType.DefaultMandatoryField__c.fields.Type__c;
    	String fullFieldName = dfr.getName();
		system.assert([Select Id from DefaultMandatoryField__c].isEmpty());

		DefaultMandatoryField__c newDefaultValue = new DefaultMandatoryField__c(
																Type__c = Schema.sObjectType.DefaultMandatoryField__c.getLabel(), 
																Name=fullFieldName,
																DefaultValue__c = Schema.sObjectType.DefaultMandatoryField__c.getLabel());  
		insert newDefaultValue;
		
		List<DefaultMandatoryField__c> newTestAccountReocrds = new List<DefaultMandatoryField__c>();
		newTestAccountReocrds.add(new DefaultMandatoryField__c()); 

		CustomMandatoryFieldManager fieldManager = new CustomMandatoryFieldManager(); 
		fieldManager.fillMandatoryFieldsIfEmpty(newTestAccountReocrds);
		system.debug('newTestAccountReocrds: '+newTestAccountReocrds);
		system.assert(newTestAccountReocrds[0].Type__c == Schema.sObjectType.DefaultMandatoryField__c.getLabel());
		
    }    
	
	static testMethod void testFillMandatoryFieldsIfEmpty_theNameFieldIsNotFilledDefaultValue() {
		Schema.DescribeFieldResult dfr = Schema.sObjectType.DefaultMandatoryField__c.fields.Type__c;
    	String fullFieldName = dfr.getName();
    	
		system.assert([Select Id from DefaultMandatoryField__c].isEmpty());
		DefaultMandatoryField__c newDefaultValue = new DefaultMandatoryField__c(
																Type__c = Schema.sObjectType.DefaultMandatoryField__c.getLabel(), 
																Name=fullFieldName,
																DefaultValue__c = Schema.sObjectType.DefaultMandatoryField__c.getLabel());  
		insert newDefaultValue;
		
		List<DefaultMandatoryField__c> newTestAccountReocrds = new List<DefaultMandatoryField__c>();
		newTestAccountReocrds.add(new DefaultMandatoryField__c(Name='test', Type__c = 'Test with my name')); 

		CustomMandatoryFieldManager fieldManager = new CustomMandatoryFieldManager(); 
		fieldManager.fillMandatoryFieldsIfEmpty(newTestAccountReocrds);
		
		system.assert(newTestAccountReocrds[0].Type__c == 'Test with my name');
		
    }
}