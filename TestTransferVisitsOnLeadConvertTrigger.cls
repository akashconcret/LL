/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestTransferVisitsOnLeadConvertTrigger {

    private static final String WEBSITE = 'http://website.com';
    private static final String CITY = 'Visit City';
    private static final String STATE = 'Visit State';
    private static final String COUNTRY = 'Visit Country';
    private static final String POSTALCODE = '12345';
    private static final String MODE = 'Automatic';

    private static void prepareSettings() {
        final Setting__c settings = TestUtils.prepareSettings();
        TestUtils.prepareTestuser();

        settings.LeadMode__c = true;
        settings.Processing__c = 'Automatic';
        settings.SelectedMode__c = 'Lead';
        settings.SelectedLeadMode__c = MODE;
        update settings;
         System.assert(true,settings.LeadMode__c);// Asserting the latest lead mode.....
    }

    @isTest
    private static void leadConversionVisitTransferTest() {

        final Company__c company = new Company__c();
        company.Name = 'testCompany';
        insert company;

        final Lead lead = new Lead();
        lead.LastName = 'TestLead';
        lead.Company = company.Name;
        insert lead;

        final Visit__c visit = new Visit__c();
        visit.Datetime__c = Date.today();
        visit.PIs__c = 5;
        visit.Lead__c = lead.Id;
        insert visit;

        final Database.LeadConvert convert = new Database.LeadConvert();
        convert.setLeadId(lead.id);

        final LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus
                                          WHERE IsConverted = true LIMIT 1];
        convert.setConvertedStatus(convertStatus.MasterLabel);

        final Database.LeadConvertResult result = Database.convertLead(convert);
        System.assert(result.isSuccess());

        final Visit__c checkVisit = [Select Lead__c, Account__c, Contact__c
                                     From Visit__c Where Id = :visit.Id];

        //verify the lead is not refernced to visit
        System.assert(checkVisit.Lead__c == null);

        //verify the account and contact is refernced to visit
        System.assert(checkVisit.Account__c != null);
    }
}