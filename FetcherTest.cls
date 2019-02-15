@IsTest
public class FetcherTest {

    @isTest
    private static void innerClassTest() {
        final Date d = Date.newInstance(2016, 06, 01);
        final Date d2 = d.addDays(1);
        // 1464735600
        //1464908400
        
        //1464739200
        //1464912000
        
        final Fetcher.IRange range = new Fetcher.DateRange(d, d2);
        System.assertEquals(range.getStart(), '1464735600');
        System.assertEquals(range.getFinish(), '1464908400');

        final Fetcher.IChunk chunk = new Fetcher.CalloutChunk(null, range.getStart(),
                range.getFinish(), 0, 10);
        System.assertEquals(chunk.getStartTime(), range.getStart());
        System.assertEquals(chunk.getFinishTime(), range.getFinish());
        System.assertEquals(0, chunk.getStart());
        System.assertEquals(10, chunk.getFinish());

        final Manager.Service manager = new ManagerMock();
        final RestClient.Service restService = new RestServiceMock(generateCompanies(10));
        final Fetcher.IRunnable runnable = new Fetcher.Company(restService, manager);
        runnable.run((Fetcher.CalloutChunk) chunk);
        runnable.finish();
        System.assertEquals(10, ((ManagerMock) manager).companies.size());
    }

    @isTest
    private static void fetcherSanityTest() {

        final Setting__c settings = new Setting__c(
            Name = Constants.CUSTOM_SETTING_NAME,
            EndpointURI__c = 'www.test.de'
        ); insert settings;

        final Date d = Date.newInstance(2016, 06, 01);
        final Date d2 = d.addDays(1);

        final Fetcher.IRange range = new Fetcher.DateRange(d, d2);
        final Fetcher fetcher = new Fetcher(range, new RestServiceMock(),false);
        final List<Fetcher.CalloutChunk> chunks = (List<Fetcher.CalloutChunk>) fetcher.start(null);
        System.assert(chunks.isEmpty());
    }

    private static List<Dto.Company> generateCompanies(Integer amount) {
        final List<Dto.Company> companies = new List<Dto.Company>();
        for(Integer i = 0; i < amount; i++) {
            final Dto.Company company = new Dto.Company();
            company.id = String.valueOf(i);
            company.ddate = Datetime.now().getTime() / 1000;
            company.name = 'Company ' + i;
            company.pages =  new List<Dto.WebPage>();
            company.referrers =  new List<Dto.Referrer>();
            company.campaigns =  new List<Dto.Campaign>();
            company.milestones =  new List<Dto.Milestone>();

            companies.add(company);
        }
        return companies;
    }

    private class RunnableMock implements Fetcher.IRunnable {
        public void run(Fetcher.CalloutChunk chunk) {

        }
        public void finish() {

        }
    }

    private class ManagerMock implements Manager.Service {

        public final List<Dto.Company> companies = new List<Dto.Company>();

        public void getCompanies(Datetime dateFrom, Datetime dateTo, Integer startpos, Integer length) {
        }
        public void persistCompanies(List<Dto.Company> companies) {
            this.companies.addAll(companies);
        }
    }

    private class RestServiceMock implements RestClient.Service {

        private final List<Dto.Company> companies = new List<Dto.Company>();

        public RestServiceMock() {
            this(new List<Dto.Company>());
        }

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
}