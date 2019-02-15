@isTest
private class TestPostInstall {
    @testSetup static void dataSetUp(){
        Group g1 = new Group(Name='Lead_Queue', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            system.assertEquals(1,[select count() from Group where name ='Lead_Queue']);
    }

    @isTest
    private static void createTenantTest() {
        final Setting__c settings = new Setting__c();
        settings.Name = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'www.test.de';
        insert settings;

        final RestClient.Service restService = new RestServiceMock();
        final PostInstall installer = new PostInstall();
        // final PostInstall installer = new PostInstall(restService, settings, new LeadWebQueueHandler());

        // installer.createTenant();
        final Setting__c updatedSettings = Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME);

        final Dto.LoginInformation loginInfo = restService.createTenant();
        // System.assertEquals(loginInfo.publicCustnum,
        //                     updatedSettings.PublicCustomNumber__c);
        System.assertEquals('www.test.de', Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).EndpointURI__c);
    }
    
    @isTest
    static void testInstallScript() {
    	PostInstall postinstall = new PostInstall();
    	Test.testInstall(postinstall, null);
    	
    	List<Group> grpQueues = [Select Id, Name, DeveloperName From Group Where (DeveloperName = 'Lead_Queue' Or DeveloperName = 'Company_Queue') And Type = 'Queue'];
    		
    	System.debug('grpQueues:: '+grpQueues);
    	
    	List<QueueSobject> qSQueues = [SELECT Id, QueueId, SobjectType FROM QueueSobject];
    		
    	System.debug('qSQueues:: '+qSQueues);
    	System.assertEquals(true,grpQueues.size()>0);
    }

    @isTest
    private static void createRequiredObjectsTest() {

        final Set<String> newlyCreatedGroupNames = new Set<String> {Constants.LeadQueue, Constants.CompanyQueue};

        // new PostInstall().createRequiredObjects();

        final Map<Id, Group> groups2 = new Map<Id, Group>([Select Id From Group Where Type = :LeadWebQueueHandler.GroupType.Queue.name() AND Name IN :newlyCreatedGroupNames]);
        System.assertEquals(2, groups2.size());

        System.assertEquals(2, [Select Id from QueueSObject Where QueueId
                In :groups2.keySet()].size());
    }

    private class RestServiceMock implements RestClient.Service {

        private final List<Dto.Company> companies = new List<Dto.Company>();

        public RestServiceMock() {}

        public Dto.LoginInformation createTenant() {
            final Dto.LoginInformation info = new Dto.LoginInformation();
            info.publicCustnum = '12345';
            info.token = '23456';
            return info;
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