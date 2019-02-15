@isTest
public with sharing class TestLeadSettings {
    ////Lead/Visit data
    //private static final String OPEN_STATUS = 'Open - Not Contacted';
    //private static final String COMPANY = 'Visit Company Name';
    //private static final String WEBSITE = 'http://website.com';
    //private static final String CITY = 'Visit City';
    //private static final String STATE = 'Visit State';
    //private static final String COUNTRY = 'Visit Country';
    //private static final String POSTALCODE = '12345';

    ////Settings
    //private static final String QUEUE = 'Some queue';
    //private static final String SOURCE = 'Some lead source';
    //private static final String CAMPAIGN_NAME = 'Some campaign';
    //private static final String MODE = 'Automatic';

    //private static final Integer MAX_VISITS = 10;

    //private static Setting__c settings;

    //private static void prepareSettings() {
    //    settings = TestUtils.prepareSettings();
    //    TestUtils.prepareTestuser();

    //    settings.LeadMode__c = true;
    //    settings.SelectedLeadMode__c = MODE;
    //    settings.SelectedQueue__c = QUEUE;
    //    settings.LeadSource__c = SOURCE;
    //    update settings;
    //}

    //public static testMethod void testCampaign() {
    //    prepareSettings();

    //    //Create campaign and use this as chosen campaign in settings
    //    Campaign campaign = new Campaign();
    //    campaign.Name = CAMPAIGN_NAME;
    //    insert campaign;
    //    settings.SelectedCampaign__c = campaign.Id;
    //    update settings;

    //    //Create visits to convert into leads
    //    final List<Visit__c> visits = new List<Visit__c>();
    //    for (Integer i = 0; i < MAX_VISITS; i++) {
    //        final Visit__c visit = new Visit__c();
    //        visit.CompanyName__c = COMPANY;
    //        visit.Datetime__c = Datetime.newInstance(2014, 01, 01);
    //        visits.add(visit);
    //    }
    //    insert visits;

    //    //Convert the leads
    //    final LeadManager leadManager = new LeadManager();
    //    final List<Lead> leads = leadManager.createLeads(visits);

    //    //Get all campaign members from the campaign we created earlier
    //    List<CampaignMember> members = [Select Id, LeadId,
    //                                    CampaignId From CampaignMember
    //                                    where CampaignId = : campaign.Id];
    //    final List<Lead> actualLeads = [Select Id From Lead];

    //    //Verify we have the same amount of campaign members as leads
    //    System.assertEquals(actualLeads.size(), members.size());

    //    //Verify 1 to 1 mapping between leads and campaign members
    //    for (Lead lead : actualLeads) {
    //        Boolean found = false;
    //        for (CampaignMember member : members) {
    //            if (lead.Id == member.LeadId)
    //                found = true;
    //        }
    //        System.assertEquals(true, found);
    //    }
    //}
}