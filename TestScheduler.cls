@isTest
public with sharing class TestScheduler {
    private static Setting__c settings;

    private static void prepare() {
        //--- create settings ---
        settings = TestUtils.prepareSettings();
        TestUtils.prepareTestuser();
        Id accOwnerId = [Select Id from User].get(0).Id;

        //--- create accounts ---
        //should be matchable by name
        Account acc = new Account();
        acc.Name = 'Dickenson plc';
        acc.OwnerId = accOwnerId;
        insert acc;

        //should be matchable by address
        acc = new Account();
        acc.Name = 'not matchable by name';
        acc.BillingPostalCode = '88410';
        acc.BillingCity = 'Bad Wurzach';
        acc.BillingState = 'Baden-Wurttemberg';
        acc.BillingCountry = 'Deutschland';
        acc.OwnerId = accOwnerId;
        insert acc;

        //should be matchable by website
        acc = new Account();
        acc.Name = 'matchable by website';
        acc.Website = 'www.burlington.com';
        acc.OwnerId = accOwnerId;
        insert acc;

        System.assert(acc != null);
    }

    // CRON expression: midnight on March 15.Because this is a test, job executes immediately after Test.stopTest().
    public static final String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static final String CRON_EXP2 = '0 0 3 * * ?';
}