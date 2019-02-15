public with sharing class RestClient implements Service {

    private final Logger.IService log = Logger.getDefault(RestClient.class);

    public interface  Service{
        Dto.LoginInformation createTenant();
        Dto.Customer getCustomer();

        List<Dto.LegalForm> getLegalForms();

        /**
         * Returns the number of visits for the given time frame
         */
        Integer getCompaniesCount(String fromTime, String toTime);
        List<Dto.Company> getCompanies(String fromTime, String toTime);
        List<Dto.Company> getCompanies(String fromTime, String toTime, Integer start, Integer length);
        List<Dto.Company> getCompanies(Datetime fromTime, Datetime toTime, Integer start, Integer length);
    }

    private enum ParamToken {
        fromTime, toTime, start, length, token
    }

    private final HttpClient.Service httpService;
    private final Setting__c settings;

    public RestClient() {
        this(HttpClient.getInstance(), new CredentialsManager().getSettings());
    }

    public RestClient(HttpClient.Service httpService, Setting__c settings) {
        this.httpService = httpService;
        this.settings = settings;
    }

    public Dto.LoginInformation createTenant() {

        final Dto.TechnicalUser technicalUser = new Dto.TechnicalUser();
        // logicline
        // llpasswd64
        technicalUser.username = 'leadlab4salesforce';
        technicalUser.password = 'zr6Szb6xHCtyh8CY';

        technicalUser.customer = new Map<String, String>();

        technicalUser.customer.put(Constants.NAME, Constants.CUSTOMER_NAME);
        technicalUser.customer.put(Constants.DOMAIN, Constants.CUSTOMER_DOMAIN);

        technicalUser.customer.put(Constants.ORG_ID, UserInfo.getOrganizationId());
        technicalUser.customer.put(Constants.ORG_NAME, UserInfo.getOrganizationName());
        
        final String resultJson = httpService.doPost(this.settings.EndpointURI__c,
                                  Constants.CREATE_TENANT_PART_URI, JSON.serialize(technicalUser), Constants.POST_METHOD,
                                  Constants.APPLICATION_JSON);


        log.debug('Creating tenant', resultJson);
        final String alteredRepsonse = resultJson.replace('"package":', '"packageName":');
        system.debug('alteredRepsonse::'+alteredRepsonse);
        final Dto.LoginResponse responseDto = (Dto.LoginResponse) 
            JSON.deserializeStrict(alteredRepsonse, Dto.LoginResponse.class);

        return responseDto.data;
    }

    public List<Dto.LegalForm> getLegalForms() {

        final Map<String, String> parameter = getBaseParams();
        final String resultJson = httpService.doGet(this.settings.EndpointURI__c,
                                  Constants.LEGAL_FORMS_PART_URI, parameter, Constants.APPLICATION_JSON);

        final Dto.LegalFormData legalFormData = (Dto.LegalFormData) JSON.deserialize(resultJson,
                                                Dto.LegalFormData.class);

        log.debug('Fetching legal forms: ', resultJson);
        return legalFormData.data;
    }

    public List<Dto.Company> getCompanies(Datetime fromTime, Datetime toTime, Integer start,
                                          Integer length) {

        return getCompanies(unixTime(fromTime), unixTime(toTime), start, length);
    }

    public List<Dto.Company> getCompanies(String fromTime, String toTime) {
        return getCompanies(fromtime, toTime, null, null);
    }

    public List<Dto.Company> getCompanies(String fromTime, String toTime, Integer start,
                                          Integer length) {


        return getCompanyFullData(fromTime, toTime, start, length).companies;
    }

    public Dto.Customer getCustomer() {
        system.debug('Test');
        final Map<String, String> params = getBaseParams();
        final String jsonResponse = httpService.doGet(this.settings.EndpointURI__c,
                                    Constants.CUSTOMER_PART_URI + this.settings.PublicCustomNumber__c, params,
                                    Constants.APPLICATION_JSON);
        system.debug('Test');
        final String alteredRepsonse = jsonResponse.replace('"package":', '"packageName":');
        final Dto.CustomerData customerData = (Dto.CustomerData) JSON.deserialize(alteredRepsonse,
                                              Dto.CustomerData.class);
        
        return customerData.data;
    }

    public Integer getCompaniesCount(String fromTime, String toTime) {
        return getCompanyFullData(fromTime, toTime, 0, 1).resultSize;
    }

    private Dto.CompanyData getCompanyFullData(String fromTime, String toTime, Integer start,
            Integer length) {

        final Map<String, String> params = convertQueryParameters(fromTime, toTime, start, length);
        final String path = Constants.CUSTOMER_PART_URI + this.settings.PublicCustomNumber__c +
                Constants.COMPANIES_PART_URI;

        final String jsonResponse = httpService.doGet(this.settings.EndpointURI__c, path, params,
                Constants.APPLICATION_JSON);

        final String alteredResponse = jsonResponse.replace('"date":', '"ddate":');
        system.debug(LoggingLevel.WARN,'alteredResponse::'+alteredResponse);
        final Dto.CompanyResponse responseDto = (Dto.CompanyResponse) JSON.deserialize(alteredResponse,
                Dto.CompanyResponse.class);

        log.debug('Response: ' + responseDto.data.companies);
        return responseDto.data;
    }

    private String unixTime(Datetime dt) {
        return String.valueOf(dt.getTime() / 1000);
    }

    private Map<String, String> convertQueryParameters(String fromTime, String toTime, Integer start,
            Integer length) {

        final Map<String, String> parameters = new Map<String, String> {
            ParamToken.fromTime.name() => fromTime,
            ParamToken.toTime.name() => toTime,
            ParamToken.start.name() => String.valueOf(start),
            ParamToken.length.name() => String.valueOf(length)
        };

        if(start != null)
            parameters.put(ParamToken.start.name(), String.valueOf(start));

        if(length != null)
            parameters.put(ParamToken.length.name(), String.valueOf(length));


        parameters.putAll(getBaseParams());

        final Map<String, String> returnParams = new Map<String, String>();
        for(String key : parameters.keySet()) {
            if(String.isNotEmpty(parameters.get(key)))
                returnParams.put(key, parameters.get(key));
        }
        return returnParams;
    }

    private Map<String, String> getBaseParams() {
        return new Map<String, String> {
            ParamToken.token.name() => this.settings.Token__c
        };
    }
}