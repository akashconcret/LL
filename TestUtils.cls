/**
 * Testklasse für die Utils und enthält auch Utility-Hilfsfunktionen, die von anderen Testklassen verwendet werden.
 */
@isTest
public with sharing class TestUtils {

    /* ----- Util-Funktionen für Testklassen ----- Start ----- */
    public static Setting__c prepareSettings() {
        Setting__c settings = new Setting__c();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.SelectedFilter__c = 'testfilter';
        settings.Websitesel__c = 'abc123';
        settings.EndpointURI__c = Constants.DEFAULT_ENDPOINT;
        settings.Filterowner__c = 'owner';
        settings.StandardTaskUser__c = null;
        settings.TimeUntilDuedate__c = 7;
        settings.AutoTaskPerAccountAssignment__c = false;
        settings.LastFetchDate__c = system.now();

        settings.LeadMode__c = false;
        settings.SelectedLeadMode__c = 'none';
        settings.LeadSource__c = '';
        settings.SelectedCampaign__c = '';
        settings.SelectedQueue__c = '';
        settings.Retrieval_Period__c = '1h';
        

        insert settings;
        System.assertEquals(false,settings.LeadMode__c);
        return settings;
    }

    public static void prepareTestuser() {
        String randomName = string.valueof(Datetime.now()).replace('-', '').replace(':',
                            '').replace(' ', '');

        User testUser = new User();
        testUser.Username = randomName + '12345@testusers_company.com';
        testUser.Email = randomName + '@company.com';
        testUser.Lastname = 'User';
        testUser.Firstname = 'Mister';
        testUser.Alias = 'test';
        testUser.CommunityNickname = 'testuser_1235_forTest';
        //testUser.UserRole = [ select id from userrole where id ='00Ei0000000XInH' ];
        //SObject prof = [ select id from profile where id = '00ei0000000lLmd' ];
        testUser.ProfileId = [select id from profile where name = 'Standard User'].Id;

        //testUser.CurrencyIsoCode = 'USD';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.UserPermissionsMobileUser = false;
        insert testUser;
        system.assertEquals('en_US',testUser.LanguageLocaleKey);
    }

    public static void assertRestCallEquality(String expected, String actual) {
        //split off params because they can be in different orders
        String[] eParts = expected.split('\\?');
        String[] aParts = actual.split('\\?');

        //check base url
        if(!eParts.isEmpty() && !aParts.isEmpty())
            System.assertEquals(eParts.get(0), aParts.get(0),
                                eParts.get(0) + '!=' + aParts.get(0));

        //check params independet from their order of appearance in endpoint
        eParts = eParts.get(1).split('\\&');
        aParts = aParts.get(1).split('\\&');
        Set<String> aPartsSet = new Set<String>();
        aPartsSet.addAll(aParts);
        for(String ePart : eParts)
            System.assert(aPartsSet.contains(ePart),
                          'Expected REST param not found: ' + ePart);
    }

    /**
     * Determines if call serves to get size of result set or if it is a 'real' call.
     */
    public static Boolean isGetLengthCall(String endpointUrl) {
        String[] eParts = endpointUrl.split('\\?');
        System.assert(!eParts.isEmpty());

        if(!eParts.isEmpty()) {
            String[] params = eParts.get(1).split('\\&');

            for(String param : params) {
                if(param.contains('length')) {
                    String val = param.split('\\=').get(1);
                    if(val == '1')
                        return true;
                }
            }
        }

        return false;
    }
    /* ----- Util-Funktionen für Testklassen ----- Ende ----- */



    public static List<Account> prepareAccounts() {
        final List<Account> accounts = new List<Account>();
        final Id accOwnerId = [Select Id from User].get(0).Id;

        Account acc = new Account();
        acc.Name = 'Dickenson plc';
        acc.OwnerId = accOwnerId;
        accounts.add(acc);

        acc = new Account();
        acc.Name = 'matchable by website';
        acc.Website = 'www.burlington.com';
        acc.OwnerId = accOwnerId;
        accounts.add(acc);
        
        insert accounts;
        system.assertEquals(2,accounts.size());
        return accounts;
    }

    public static List<Task> prepareTasks() {
        final List<Task> tasks = new List<Task>();

        Task t = new Task();
        t.Subject = 'Call';
        t.OwnerId = UserInfo.getUserId();
        t.WhatId = [Select Id from Account order by Id asc].get(0).Id;
        t.ActivityDate = Datetime.now().date();
        //t.IsTask__c = true;
        tasks.add(t);

        insert tasks;
        system.assertEquals(1,tasks.size());
        return tasks;
    }

    public static List<PageHit__c> preparePageHits(final List<Visit__c> visits) {
        final List<PageHit__c> pageHits = new List<PageHit__c>();

        PageHit__c pageHit = new PageHit__c();
        // pageHit.Page__c = 'foo';
        pageHit.Hits__c = 1;
        pageHit.Visit__r = visits.get(0);
        pageHit.Visit__c = visits.get(0).Id;
        pageHits.add(pageHit);

        pageHit = new PageHit__c();
        // pageHit.Page__c = 'bar';
        pageHit.Hits__c = 1;
        pageHit.Visit__r = visits.get(1);
        pageHit.Visit__c = visits.get(1).Id;
        pageHits.add(pageHit);

        pageHit = new PageHit__c();
        // pageHit.Page__c = 'baz';
        pageHit.Hits__c = 1;
        pageHit.Visit__r = visits.get(2);
        pageHit.Visit__c = visits.get(2).Id;
        pageHits.add(pageHit);
        system.assertEquals(visits.size(),pageHits.size());
        insert pageHits;
        return pageHits;
    }
}