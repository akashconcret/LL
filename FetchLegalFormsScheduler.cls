public with sharing class FetchLegalFormsScheduler implements Schedulable {

    private final static String scheduleName = FetchLegalFormsScheduler.class.getName();
    // runs at 0 AM on 1st and 15th day of month
    private final static String everyTwoWeeksCron = '0 0 0 1,15 * ?';

    public void execute(SchedulableContext context) {
        FetchLegalFormsScheduler.fetchLegalForms();
    }

    @future(callout=true)
    public static void fetchlegalForms() {
        new FetchLegalFormsScheduler().fetchLegalForms(new RestClient());
    }

    public void fetchlegalForms(RestClient.Service restService) {
        final List<LegalForm__c> legalForms = new List<LegalForm__c>();
        for(Dto.LegalForm legalFormDto : restService.getLegalForms()) {
            final LegalForm__c legalForm = new LegalForm__c();
            legalform.LegalForm__c = legalFormDto.legalForm;
            legalform.FastMatch__c = legalFormDto.fastMatch;
            legalform.ReversedFastMatch__c = legalFormDto.reversedFastMatch;
            legalform.Length__c = legalFormDto.length;
            legalform.CountryISOCode__c = legalFormDto.cc2;
            legalForms.add(legalForm);
        }
        DMLManager.upsertByFieldAsSystem(legalForms, 'LegalForm__c');
    }

    public static void schedule() {
        if(![Select Name From CronJobDetail Where Name = : schedulename].isEmpty())
            return;

        fetchLegalForms();

        System.schedule(scheduleName, everyTwoWeeksCron, new FetchLegalFormsScheduler());
    }
}