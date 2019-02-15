@isTest
public with sharing class TestSettingsController {
    private static Setting__c settings;
    
    // @testSetup static void settingsTest() {
        
    // }
    
    private static void prepare() {
        settings = TestUtils.prepareSettings();
        settings.SelectedMode__c = Mode.Type.Company.name();
        update settings;

        insert new Group(Name = 'Leadweb Group', Type = 'Queue');
    }

    @isTest
    private static void constructorTest() {
        Test.setMock(HttpCalloutMock.class, new LeadWebHttpResponseGenerator());
        prepare();

        final SettingsController ctrl = new SettingsController();
        System.assert(!ctrl.getLeadSourceOptions().isEmpty());
        System.assert(!ctrl.getCampaignOptions().isEmpty());
        System.assert(!ctrl.getProcessingOptions().isEmpty());
        System.assert(!ctrl.getVisitLimits().isEmpty());
        // System.assert(ctrl.cancel() == null);
        System.assert(!ctrl.leadMapping);
        System.assert(ctrl.leadUserOptions == null);
        System.assert(String.isEmpty(ctrl.selectedCompanyUser));
        System.assert(String.isEmpty(ctrl.selectedLeadUser));
        // System.assert(ctrl.isSearchPhrasesEnabled == null);
        // System.assert(ctrl.isReferrersEnabled == null);
        System.assert(ctrl.isAccountActive != null);
        System.assert(ctrl.isPixelCodeActive != null);
        // System.assert(ctrl.isPagesEnabled != null);
        // System.assert(ctrl.isMilestonesEnabled == null);
        // System.assert(ctrl.isCampaignsEnabled == null);
        System.assert(ctrl.packageName == null);
        System.assert(ctrl.detectedCompanies != null);
        System.assert(String.isNotEmpty(ctrl.lastFetchDate));
        System.assert(ctrl.deleteAllVisits() == null);
        ctrl.saveSetting();
        
        ctrl.selectedMode = 'Lead';
        ctrl.leadName = 'Release';
        ctrl.saveSetting();
        
        system.assertEquals('Release', string.valueof(Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).get('LeadName__c')));
        
        ctrl.initConnection();
        ctrl.getRetrievalPeriods();
        ctrl.selectedMode = 'Account';
        
        ctrl.saveSetting();
        
    }

    @isTest
    private static void mockedCalloutTest() {
        prepare();

        final SettingsController ctrl = new SettingsController(new RestServiceMock());
        ctrl.getStatisticsInfo();
        System.assert(!ctrl.readyToFetch());
        ctrl.autoLeadProcessing = true;
        ctrl.pisCurrent = 1234;
        ctrl.pisLimit = 10000;
        ctrl.getConnectionStarted();
        ctrl.save();
        ctrl.cancel();
        ctrl.edit();
        system.assertEquals(true,ctrl.editmode);
        ctrl.testGroupQueue();
        //System.assert(ctrl.save() == null);
    }
    private static testmethod void fetchVisitsTest(){
        Test.setMock(HttpCalloutMock.class, new LeadWebHttpResponseGenerator());
        Dto.LoginResponse lr = new Dto.LoginResponse();
        settings = TestUtils.prepareSettings();
        SettingsController ctrl = new SettingsController();
        
        ctrl.fromDate = date.newInstance(2017,01,24);
        ctrl.toDate = date.newInstance(2017,01,25);
        
        Test.startTest();
         ctrl.fetchVisits();
         
      Test.stopTest();
      system.assertEquals('1h',settings.Retrieval_Period__c);
    }

    private class RestServiceMock implements RestClient.Service {

        private final List<Dto.Company> companies = new List<Dto.Company>();
        private final Dto.LoginInformation loginInfo = new Dto.LoginInformation();

        public RestServiceMock() {
            this(new List<Dto.Company>());
        }

        public RestServiceMock(List<Dto.Company> companies) {
            this.companies.addAll(companies);
        }

        public Dto.LoginInformation createTenant() {
            return this.loginInfo;
        }
        public Dto.Customer getCustomer() {
            return new Dto.Customer();
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
}