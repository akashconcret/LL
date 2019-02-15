@isTest
private class TestFetchLegalFormsScheduler {

    private static Setting__c settings;

    private static void prepare() {
        if (settings == null)
            settings = TestUtils.prepareSettings();
    }

    public static final String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void testFetchScheduler_schedulerIsScheduled() {
        prepare();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TEST_GET_LEGAL_FORMS');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', Constants.APPLICATION_JSON);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        // Schedule the test job
        String jobName = 'test' + Constants.LEGAL_FORM_SCHEDULER_NAME;
        String jobId = System.schedule(jobName, CRON_EXP,
                                       new FetchLegalFormsScheduler());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        List<LegalForm__c> legalForms = [SELECT LegalForm__c,
                                         CountryISOCode__c FROM LegalForm__c];
        System.assertEquals(0, legalForms.size());
        Test.stopTest();
    }

    static testmethod void testFetchScheduler_fetchLegalForms() {
        prepare();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TEST_GET_LEGAL_FORMS');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', Constants.APPLICATION_JSON);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        FetchLegalFormsScheduler.fetchLegalForms();
        Test.stopTest();

        List<LegalForm__c> legalForms = [SELECT LegalForm__c,
                                         CountryISOCode__c FROM LegalForm__c];
        System.assertEquals(2, legalForms.size());
    }

    static testmethod void testFetchScheduler_fetchLegalFormsUpdate() {
        prepare();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TEST_GET_LEGAL_FORMS');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', Constants.APPLICATION_JSON);
        Test.setMock(HttpCalloutMock.class, mock);

        insert new LegalForm__c (
            LegalForm__c = 'A G',
            CountryISOCode__c = 'qq',
            FastMatch__c = 'a g',
            ReversedFastMatch__c = 'g a',
            Length__c = 3
        );

        Test.startTest();
        FetchLegalFormsScheduler.fetchLegalForms();
        Test.stopTest();

        List<LegalForm__c> legalForms = [SELECT LegalForm__c,
                                         CountryISOCode__c FROM LegalForm__c];
        System.assertEquals(2, legalForms.size());

        for (LegalForm__c lf : legalForms) {
            if (lf.LegalForm__c == 'A G')
                System.assertEquals('de', lf.CountryISOCode__c);
        }
    }

}