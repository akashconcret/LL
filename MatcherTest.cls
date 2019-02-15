@isTest
private class MatcherTest {

    @isTest static void testMatcher() {
        final Matcher.Service positiveMatcher = new Matcher(new FacadeMockSuccess());
        System.assert(positiveMatcher.match(new VisitMock()));

        final Matcher.Service negativeMatcher = new Matcher(new FacadeMockFailure());
        System.assert(!negativeMatcher.match(new VisitMock()));
    }

    @isTest static void testEmptyFacade() {
        final Matcher.IFacadeService facade = new Matcher.AccountLeadFacade();

        System.assert(!facade.hasKey(null));
        System.assert(!facade.hasKey('abcdef'));

        System.assert(!facade.fuzzyMatch(new VisitMock()));
    }

    @isTest static void testAccountKeyMatchFacade() {

        final Map<String, Account> accounts = new Map<String, Account> {
            'abcdef' => new Account(
                Id__c = 'abcdef',
                Name = 'test')
        };
        final Map<String, Lead> leads = new Map<String, Lead>();
        final Map<String, LegalForm__c> legalForms = new Map<String, LegalForm__c>();

        final Matcher.IFacadeService facade = new Matcher.AccountLeadFacade(accounts, leads, legalForms);

        final Manager.IVisit visit = new VisitMock();
        visit.getCompany().Id__c = 'abdef';

        System.assert(facade.hasKey('abcdef'));
    }

    @isTest static void testAccountBillingAddressAndDomainMatchFacade() {

        final Account acc = new Account(
            BillingPostalCode = '1234',
            BillingCountry = 'de',
            BillingCity = 'stuttgart',
            Website = 'www.site.de',
            Name = 'test');
        insert acc;

        final Matcher.IFacadeService facade = new Matcher.AccountLeadFacade();

        final Manager.IVisit visit = new VisitMock();
        visit.getCompany().Id__c = 'nonmatchid';
        visit.getCompany().City__c = 'stuttgart';
        visit.getCompany().Zip__c = '1234';
        visit.getCompany().CountryName__c = 'de';
        visit.getCompany().Domain__c = 'www.site.de';

        System.assert(facade.fuzzyMatch(visit));
        facade.convert(visit);

        System.assertEquals(acc.Id, visit.getVisit().Account__c);
        System.assertEquals(null, visit.getVisit().Company__c);
        System.assertEquals(null, visit.getVisit().Lead__c);
    }

    @isTest static void testLeadAddressAndDomainMatchFacade() {

        final Lead lead = new Lead(
            PostalCode = '1234',
            Country = 'de',
            City = 'stuttgart',
            Website = 'www.site.de',
            LastName = 'test',
            Company = 'test');
        insert lead;

        final Matcher.IFacadeService facade = new Matcher.AccountLeadFacade();

        final Manager.IVisit visit = new VisitMock();
        visit.getCompany().Id__c = 'nonmatchid';
        visit.getCompany().City__c = 'stuttgart';
        visit.getCompany().Zip__c = '1234';
        visit.getCompany().CountryName__c = 'de';
        visit.getCompany().Domain__c = 'www.site.de';

        System.assert(facade.fuzzyMatch(visit));
        facade.convert(visit);

        System.assertEquals(lead.Id, visit.getVisit().Lead__c);
        System.assertEquals(null, visit.getVisit().Company__c);
        System.assertEquals(null, visit.getVisit().Account__c);
    }


    @isTest static void testLeadKeyMatchFacade() {

        final Map<String, Account> accounts = new Map<String, Account>();
        final Map<String, Lead> leads = new Map<String, Lead> {
            'abcdef' => new Lead(
                Id__c = 'abcdef',
                LastName = 'test',
                Company = 'test')
        };
        final Map<String, LegalForm__c> legalForms = new Map<String, LegalForm__c>();

        final Matcher.IFacadeService facade = new Matcher.AccountLeadFacade(accounts, leads, legalForms);

        final Manager.IVisit visit = new VisitMock();
        visit.getCompany().Id__c = 'abdef';

        System.assert(facade.hasKey('abcdef'));
    }

    public class FacadeMockSuccess implements Matcher.IFacadeService {
        public Boolean hasKey(String externalId) {
            return true;
        }
        public void convert(Manager.IVisit visitInfo) {}

        public Boolean fuzzyMatch(Manager.IVisit visitInfo) {
            return true;
        }
    }

    public class FacadeMockFailure implements Matcher.IFacadeService {
        public Boolean hasKey(String externalId) {
            return false;
        }
        public void convert(Manager.IVisit visitInfo) {}

        public Boolean fuzzyMatch(Manager.IVisit visitInfo) {
            return false;
        }
    }

    private class VisitMock implements Manager.IVisit {
        private final Visit__c visit = new Visit__c();
        private final Company__c company = new Company__c();

        public Visit__c getVisit() {
            return this.visit;
        }
        public Company__c getCompany() {
            return this.company;
        }
        public List<PageHit__c> getPageHits() {
            return new List<PageHit__c>();
        }
        public List<Referrer__c> getReferrers() {
            return new List<Referrer__c>();
        }
        /*public List<Campaign__c> getCampaigns() {
            return new List<Campaign__c>();
        }*/
        public List<Milestone__c> getMilestones() {
            return new List<Milestone__c>();
        }
    }


}