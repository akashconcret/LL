@isTest
public with sharing class TestFetchVisitsScheduler {

    //private static Setting__c settings;

    //private static void prepare() {
    //    if(settings == null)
    //        settings = TestUtils.prepareSettings();
    //}

    //public static final String CRON_EXP = '0 0 0 15 3 ? 2022';

    //static testmethod void testFetchScheduler_schedulerIsScheduled() {
    //    prepare();

    //    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('TEST_GET_COMPANY_ONE');
    //    mock.setStatusCode(200);
    //    mock.setHeader('Content-Type', Constants.APPLICATION_JSON);
    //    Test.setMock(HttpCalloutMock.class, mock);

    //    Test.startTest();

    //    Map<String, Object> paramName_paramValue = new Map<String, Object>();
    //    paramName_paramValue.put(Constants.START_POSITION,
    //                             Constants.START_DEFAULT_FETCH_POSITION);


    //    // Schedule the test job
    //    String jobId = System.schedule(Constants.SCHEDULER_NAME_FETCH_AFTER_CLICK,
    //                                   CRON_EXP, new FetchVisitsScheduler(paramName_paramValue));

    //    // Get the information from the CronTrigger API object
    //    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
    //                      NextFireTime
    //                      FROM CronTrigger WHERE id = :jobId];

    //    System.assertEquals(CRON_EXP, ct.CronExpression);
    //    // Verify the job has not run
    //    System.assertEquals(0, ct.TimesTriggered);
    //    Visit__c [] visits = [SELECT Name FROM Visit__c];
    //    System.assertEquals(visits.size(), 0);
    //    Test.stopTest();

    //}

    //static testmethod void testFetchScheduler_dailySchedulerIsScheduled() {
    //    prepare();

    //    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('TEST_GET_COMPANY_ONE');
    //    mock.setStatusCode(200);
    //    mock.setHeader('Content-Type', Constants.APPLICATION_JSON);
    //    Test.setMock(HttpCalloutMock.class, mock);

    //    Test.startTest();
    //    Map<String, Object> paramName_paramValue = new Map<String, Object>();
    //    paramName_paramValue.put(Constants.START_POSITION,
    //                             Constants.START_DEFAULT_FETCH_POSITION);

    //    // Schedule the test job
    //    String jobId = System.schedule(Constants.SCHEDULER_NAME_FETCH_AFTER_CLICK,
    //                                   CRON_EXP, new FetchVisitsScheduler(paramName_paramValue));

    //    // Get the information from the CronTrigger API object
    //    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
    //                      NextFireTime
    //                      FROM CronTrigger WHERE id = :jobId];
    //    User user = [SELECT Id, IsAdmin__c FROM User WHERE Id = : UserInfo.getUserId()];
    //    user.IsAdmin__c = true;
    //    update user;

    //    SettingsController settingsController = new SettingsController();

    //    settingsController.scheduleFetching();

    //    // Validate fetch scheduler is scheduled
    //    System.assertEquals(Utils.cronJobExists(
    //                            Constants.SCHEDULER_NAME_FETCH_AFTER_CLICK), true);

    //    Test.stopTest();
    //}

    //static testmethod void testFetchScheduler_testFetchFutureMethod() {
    //    prepare();

    //    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    //    mock.setStaticResource('TEST_GET_COMPANY_ONE');
    //    mock.setStatusCode(200);
    //    mock.setHeader('Content-Type', Constants.APPLICATION_JSON);
    //    Test.setMock(HttpCalloutMock.class, mock);

    //    Test.startTest();

    //    FetchVisitsScheduler.fetchVisits(null, null, 0);

    //    Test.stopTest();

    //    List<Visit__c> visits = [SELECT Id, Domain__c, CompanyName__c, region__c,
    //                             zip__c, country_Name__c FROM  Visit__c];

    //    //check content of output
    //    System.assertEquals(1, visits.size());
    //    Visit__c visit = visits.get(0);

    //    System.assertEquals('cuestonet.com.br', visit.Domain__c);
    //    System.assertEquals('Wandick Evangelista Da Silva Ibitinga Me',
    //                        visit.CompanyName__c);
    //    System.assertEquals('Sao Paulo', visit.region__c);
    //    System.assertEquals('14940-00', visit.zip__c);
    //    //System.assertEquals('Ibitinga', visit.city__c);
    //    System.assertEquals('Brazil', visit.country_Name__c);
    //}

}