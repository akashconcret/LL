@IsTest
public with sharing class AccountManagerTest {

    @isTest
    private static void testAccountManager() {

        final Setting__c settings = new Setting__c();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.AutoTaskPerAccountAssignment__c = false;
        settings.EndpointURI__c = 'http://test.com';
        insert settings;

        final AccountManager accMan = new AccountManager();
        System.assert(accMan != null);
    }
}