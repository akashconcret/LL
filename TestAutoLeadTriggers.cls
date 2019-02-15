@isTest
public with sharing class TestAutoLeadTriggers {

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
    //private static final String SOURCE = 'leadweb';
    //private static final String CAMPAIGN = 'Some campaign';
    //private static final String MODE = 'Automatic';

    //private static void prepareSettings() {
    //    final Setting__c settings = TestUtils.prepareSettings();
    //    TestUtils.prepareTestuser();

    //    settings.SelectedMode__c = 'Lead';
    //    settings.Processing__c = 'Automatic';

    //    update settings;
    //}

    //private static Visit__c insertVisit() {
    //    final Visit__c visit = new Visit__c();
    //    visit.CompanyName__c = 'Visit Company Name';
    //    visit.Datetime__c = Datetime.newInstance(2014, 01, 01);

    //    visit.Domain__c = WEBSITE;
    //    //visit.City__c = CITY;
    //    visit.Region__c = STATE;
    //    visit.Country_Name__c = COUNTRY;
    //    visit.Zip__c = POSTALCODE;
    //    insert visit;
    //    return visit;
    //}

    //public static testMethod void testNewLeads() {

    //    final Setting__c settings = TestUtils.prepareSettings();
    //    settings.SelectedMode__c = 'Lead';
    //    settings.Processing__c = 'Automatic';
    //    update settings;

    //    //Check no leads exist
    //    System.assertEquals(0, [Select Id From Lead].size());

    //    //Insert a new visit => new Lead is created
    //    final Visit__c visit = insertVisit();

    //    final List<Lead> leads = [Select Id, Status, LastName, LeadSource, Company,
    //                              Website, City,
    //                              State, Country, PostalCode From Lead];
    //    System.assertEquals(0, leads.size());

    //    //Verify created lead has the same information as the visit
    //    //final Lead lead = leads.get(0);
    //    //System.assertEquals(OPEN_STATUS, lead.Status);
    //    //System.assertEquals(LASTNAME, lead.LastName);
    //    //System.assertEquals(SOURCE, lead.LeadSource);
    //    //System.assertEquals(COMPANY, lead.Company);
    //    //System.assertEquals(WEBSITE, lead.Website);
    //    //System.assertEquals(CITY, lead.City);
    //    //System.assertEquals(STATE, lead.State);
    //    //System.assertEquals(COUNTRY, lead.Country);
    //    //System.assertEquals(POSTALCODE, lead.PostalCode);

    //    ////Verify visit is now associated with lead
    //    //final Visit__c retrievedVisit = [Select Id, Lead__c from Visit__c limit 1].get(0);
    //    //System.assertEquals(lead.Id, retrievedVisit.Lead__c);
    //}

    //public static testMethod void testExistingLeads() {
    //    prepareSettings();

    //    //Insert a new visit => new Lead is created
    //    final List<Visit__c> visits = new List<Visit__c>();
    //    visits.add(insertVisit());

    //    //Insert second matching visit => visit added to existing lead
    //    visits.add(insertVisit());

    //    final List<Lead> leads = [Select Id, Status, LastName, LeadSource, Company,
    //                              Website, City,
    //                              State, Country, PostalCode From Lead];
    //    System.assertEquals(0, leads.size());

    //    //Verify created lead has the same information as the visit
    //    //final Lead lead = leads.get(0);
    //    //System.assertEquals(OPEN_STATUS, lead.Status);
    //    //System.assertEquals(LASTNAME, lead.LastName);
    //    //System.assertEquals(SOURCE, lead.LeadSource);
    //    //System.assertEquals(COMPANY, lead.Company);
    //    //System.assertEquals(WEBSITE, lead.Website);
    //    //System.assertEquals(CITY, lead.City);
    //    //System.assertEquals(STATE, lead.State);
    //    //System.assertEquals(COUNTRY, lead.Country);
    //    //System.assertEquals(POSTALCODE, lead.PostalCode);

    //    //for(Visit__c visit : [Select Id, Lead__c from Visit__c]) {
    //    //    System.assertEquals(lead.Id, visit.Lead__c);
    //    //}
    //}

    //public static testMethod void testExistingAccount() {
    //    prepareSettings();

    //    final Account acc = new Account();
    //    acc.Name = COMPANY;
    //    acc.Website = WEBSITE;
    //    acc.BillingPostalCode = POSTALCODE;
    //    acc.BillingCity = CITY;
    //    acc.BillingState = STATE;
    //    acc.BillingCountry = COUNTRY;
    //    insert acc;

    //    //Insert a new visit => visit assigned to account
    //    insertVisit();

    //    final Account retrievedAccount = [Select Id From Account limit 1].get(0);

    //    final Visit__c visit = [Select Id,
    //                            Account__c From Visit__c limit 1].get(0);
    //    System.assertEquals(null, visit.Account__c);
    //}
}