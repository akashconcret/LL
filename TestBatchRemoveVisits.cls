@isTest
public class TestBatchRemoveVisits {

    private final static Integer visitLimit = 2;

    @isTest
    private static void schedulerTest() {
        prepare();

        final Integer existingJobs = [Select Id, CronJobDetail.Name From CronTrigger].size();

        Test.startTest();
        BatchRemoveVisits.scheduleHourly();
        System.assert([SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger ].size() > 0);
        BatchRemoveVisits.abortJobs();
        Test.stopTest();
    }

    @isTest
    private static void leadLocatorTest() {
        final BatchRemoveVisits.IQueryLocator locator = new BatchRemoveVisits.LeadLocator();

        final Lead lead = new Lead();
        lead.LastName = 'test';
        lead.Company = 'test';
        insert lead;

        System.assertEquals(1, Database.query(locator.getQueryLocator().getQuery()).size());
        System.assert(String.isNotEmpty(locator.getName()));

        final List<Visit__c> visits = generateVisits(10);
        for(Visit__c visit : visits)
            visit.Lead__c = lead.Id;

        insert visits;

        prepare();
        Test.startTest();
        final BatchRemoveVisits remover = new BatchRemoveVisits(locator);
        Database.executeBatch(remover);
        Test.stopTest();

        System.assertEquals(visitLimit, [Select Id From Visit__c].size());
    }

    @isTest
    private static void accountLocatorTest() {
        final BatchRemoveVisits.IQueryLocator locator = new BatchRemoveVisits.AccountLocator();

        final Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        System.assertEquals(1, Database.query(locator.getQueryLocator().getQuery()).size());
        System.assert(String.isNotEmpty(locator.getName()));

        final List<Visit__c> visits = generateVisits(10);
        for(Visit__c visit : visits)
            visit.Account__c = acc.Id;

        insert visits;

        prepare();
        Test.startTest();
        final BatchRemoveVisits remover = new BatchRemoveVisits(locator);
        Database.executeBatch(remover);
        Test.stopTest();

        System.assertEquals(visitLimit, [Select Id From Visit__c].size());
    }

    @isTest
    private static void companyLocatorTest() {
        final BatchRemoveVisits.IQueryLocator locator = new BatchRemoveVisits.CompanyLocator();

        final Company__c company = new Company__c();
        company.Name = 'test';
        company.id__c = 'hfbhdfbv';
        insert company;

        System.assertEquals(1, Database.query(locator.getQueryLocator().getQuery()).size());
        System.assert(String.isNotEmpty(locator.getName()));

        final List<Visit__c> visits = generateVisits(10);
        for(Visit__c visit : visits)
            visit.Company__c = company.Id;

        insert visits;

        prepare();
        Test.startTest();
        final BatchRemoveVisits remover = new BatchRemoveVisits(locator);
        Database.executeBatch(remover);
        Test.stopTest();

        System.assertEquals(visitLimit, [Select Id From Visit__c].size());
    }


    private static void prepare() {
        final Setting__c settings = new Setting__c();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'www.test.de';
        settings.DeleteOldVisitsThreshold__c = visitLimit;
        insert settings;
    }

    private static List<Visit__c> generateVisits(Integer amount) {
        final List<Visit__c> visits = new List<Visit__c>();
        for(Integer i = 0; i < amount; i++)
            visits.add(new Visit__c(Datetime__c = Date.today().addDays(-i), PIs__c = i));
        return visits;
    }
    @isTest
    private static void batchDelete() {
        final Company__c company = new Company__c();
        company.Name = 'test';
        company.id__c = 'hfbhdfbv';
        insert company;

        final List<Visit__c> visits = generateVisits(10);
        for(Visit__c visit : visits)
            visit.Company__c = company.Id;

        insert visits;
        Test.startTest();
        final BatchDeleteVisits remover = new BatchDeleteVisits(system.today(),system.today());
        Database.executeBatch(remover);
        Test.stopTest();
        system.assertEquals(true,[select id from Visit__c].size()==0);
    }
}