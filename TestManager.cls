@isTest
public with sharing class TestManager {

    @isTest
    private static void testConstruction() {
        final Setting__c settings = new Setting__c();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        insert settings;

        final Manager.Service manager = new Manager();
        System.assert(manager != null);
    }

    @isTest
    private static void persistCompanyModeTest() {

        final Integer companiesToRetrieve = 10;

        final RestClient.Service restClient = new RestServiceMock(generateCompanies(companiesToRetrieve));
        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Company.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        insert settings;

        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);
        System.assertEquals(0, [Select Id From Lead].size());
        System.assertEquals(0, [Select Id From Account].size());
        System.assertEquals(companiesToRetrieve, [Select Id From Company__c].size());
    }

    @isTest
    private static void persistAccountModeTest() {

        final Integer companiesToRetrieve = 10;

        final RestClient.Service restClient = new RestServiceMock(generateCompanies(companiesToRetrieve));
        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Account.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        insert settings;

        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);
        System.assertEquals(0, [Select Id From Company__c].size());
        System.assertEquals(0, [Select Id From Lead].size());
        System.assertEquals(companiesToRetrieve, [Select Id From Account].size());
    }

    private static void persistCompanyWithQueue() {
        final Group companyQueue = new Group(Name = Constants.CompanyQueue, Type = 'Queue');
        insert companyQueue;
        insert new QueueSObject(QueueId = companyQueue.Id, SObjectType = Company__c.getSObjectType().getDescribe().getName());

        final User user = new User();
        insert user;

        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Company.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        settings.SelectedQueue__c = companyQueue.Id;
        settings.StandardCompanyUser__c = user.Id;
        insert settings;

        final Integer companiesToRetrieve = 1;

        final RestClient.Service restClient = new RestServiceMock(generateCompanies(companiesToRetrieve));
        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);
        System.assertEquals(companiesToRetrieve, [Select Id From Company__c].size());
        System.assertEquals(0, [Select Id From Lead].size());
        System.assertEquals(0, [Select Id From Account].size());

        for(Company__c company : [Select Id, OwnerId From Company__c]) {
            System.assertEquals(settings.SelectedQueue__c, company.OwnerId);
        }
    }

    private static void persistCompanyWithStandardUser() {
        final Group companyQueue = new Group(Name = Constants.CompanyQueue, Type = 'Queue');
        insert companyQueue;
        insert new QueueSObject(QueueId = companyQueue.Id, SObjectType = Company__c.getSObjectType().getDescribe().getName());

        final User user = new User();
        insert user;

        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Company.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        settings.StandardCompanyUser__c = user.Id;
        insert settings;

        final Integer companiesToRetrieve = 1;

        final RestClient.Service restClient = new RestServiceMock(generateCompanies(companiesToRetrieve));
        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);
        System.assertEquals(companiesToRetrieve, [Select Id From Company__c].size());
        System.assertEquals(0, [Select Id From Lead].size());
        System.assertEquals(0, [Select Id From Account].size());

        for(Company__c company : [Select Id, OwnerId From Company__c]) {
            System.assertEquals(settings.StandardCompanyUser__c, company.OwnerId);
        }
    }

    @isTest
    private static void persistAccountsWithSpecialCharacters() {

        //Company DTOs to lead names which should match
        final Map<String, String> nameMapping = new Map<String, String> {
            'Compäny' => 'Company',
            'test' => 'teßt'
        };

        final List<Dto.Company> companies = generateCompanies(nameMapping.keySet().size());
        final List<Account> accounts = new List<Account>();
        for(Integer i=0; i<companies.size(); i++) {
            final String name = new List<String>(nameMapping.keySet()).get(i);
            companies.get(i).name = name;
            final Account account = new Account(Name = nameMapping.get(name));
            accounts.add(account);
        }
        insert accounts;

        final RestClient.Service restClient = new RestServiceMock(companies);
        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Account.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        insert settings;

        System.assertEquals(nameMapping.size(), [Select Id From Account].size());

        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);

        System.assertEquals(0, [Select Id From Company__c].size());
        System.assertEquals(0, [Select Id From Lead].size());
        System.assertEquals(nameMapping.size(), [Select Id From Account].size());
    }

    @isTest
    private static void persistLeadModeTest() {

        final Integer companiesToRetrieve = 10;

        final RestClient.Service restClient = new RestServiceMock(generateCompanies(companiesToRetrieve));
        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Lead.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        insert settings;

        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);
        System.assertEquals(0, [Select Id From Company__c].size());
        System.assertEquals(companiesToRetrieve, [Select Id From Lead].size());
        System.assertEquals(0, [Select Id From Account].size());
    }

    @isTest
    private static void persistLeadsWithSpecialCharacters() {

        //Company DTOs to lead names which should match
        final Map<String, String> nameMapping = new Map<String, String> {
            'Compäny' => 'Company',
            'test' => 'teßt'
        };

        final List<Dto.Company> companies = generateCompanies(nameMapping.keySet().size());
        final List<Lead> leads = new List<Lead>();
        for(Integer i=0; i<companies.size(); i++) {
            final String name = new List<String>(nameMapping.keySet()).get(i);
            companies.get(i).name = name;
            final Lead lead = new Lead(Company = nameMapping.get(name), LastName = 'test');
            leads.add(lead);
        }
        insert leads;

        final RestClient.Service restClient = new RestServiceMock(companies);
        final Setting__c settings = new Setting__c();
        settings.SelectedMode__c = Mode.Type.Lead.name();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'endpoint';
        insert settings;

        System.assertEquals(nameMapping.size(), [Select Id From Lead].size());

        final Manager.Service manager = new Manager(restClient, settings);
        manager.getCompanies(null, null, null, null);

        System.assertEquals(0, [Select Id From Company__c].size());
        System.assertEquals(nameMapping.size(), [Select Id From Lead].size());
        System.assertEquals(0, [Select Id From Account].size());
    }

    private static List<Dto.Company> generateCompanies(Integer amount) {
        final List<Dto.Company> companies = new List<Dto.Company>();
        for(Integer i = 0; i < amount; i++) {
            final Dto.Company company = new Dto.Company();
            company.id = String.valueOf(i);
            company.ddate = Datetime.now().getTime() / 1000;
            company.name = 'Company ' + i;
            company.pis=2;
            company.pages =  new List<Dto.WebPage>();
            company.referrers =  new List<Dto.Referrer>();
            company.campaigns =  new List<Dto.Campaign>();
            company.milestones =  new List<Dto.Milestone>();

            companies.add(company);
        }
        return companies;
    }

    private class RestServiceMock implements RestClient.Service {

        private final List<Dto.Company> companies = new List<Dto.Company>();

        public RestServiceMock(List<Dto.Company> companies) {
            this.companies.addAll(companies);
        }

        public Dto.LoginInformation createTenant() {
            return null;
        }
        public Dto.Customer getCustomer() {
            return null;
        }
        public List<Dto.LegalForm> getLegalForms() {
            return new List<Dto.LegalForm>();
        }
        public List<Dto.Company> getCompanies(String fromTime, String toTime) {
            return companies;
        }
        public List<Dto.Company> getCompanies(String fromTime, String toTime, Integer start,
                                              Integer length) {
            return companies;
        }
        public List<Dto.Company> getCompanies(Datetime fromTime, Datetime toTime, Integer start,
                                              Integer length) {
            return companies;
        }

        public Integer getCompaniesCount(String fromTime, String toTime) {
            return companies.size();
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