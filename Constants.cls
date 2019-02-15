public with sharing class Constants {
    
   //map that holds fields mapping between company and lead.
   public static Map<String,String> companyLeadMap = new Map<String,String>{
       //Sobject Field => Company Field.
      'lastname' => 'name',
       'company' => 'name',
       'phone' => 'wmll__phone__c',
       'email' => 'wmll__email__c',
       'website' => 'wmll__domain__c',
       'street' => 'wmll__street__c',
       'postalcode' => 'wmll__zip__c',
       'city' => 'wmll__city__c',
       'state' => 'wmll__region__c',
       'country' => 'wmll__countryname__c',
       'wmll__leadlab4sf_industry__c' => 'wmll__branch__c',
       'wmll__leadlab4sf_annual_revenue__c' => 'wmll__annualrevenue__c',
       'wmll__leadlab4sf_no_of_employees__c' => 'wmll__size__c',
       'status' => 'wmll__lead_status__c',
       'rating' => 'wmll__rating__c',
       'wmll__id__c' => 'wmll__id__c'
       };
    
   //map that holds fields mapping between company and account.
   public static Map<String,String> companyAccountMap = new Map<String,String>{
           //Sobject Field => Company Field.
      'name' => 'name',
       'phone' => 'wmll__phone__c',
       'fax' => 'wmll__fax__c',
       'website' => 'wmll__domain__c',
       'billingstreet' => 'wmll__street__c',
       'billingpostalcode' => 'wmll__zip__c',
       'billingcity' => 'wmll__city__c',
       'billingstate' => 'wmll__region__c',
       'billingcountry' => 'wmll__countryname__c',
       'shippingstreet' => 'wmll__street__c',
       'shippingpostalcode' => 'wmll__zip__c',
       'shippingcity' => 'wmll__city__c',
       'shippingstate' => 'wmll__region__c',
       'shippingcountry' => 'wmll__countryname__c',
       'wmll__leadlab4sf_industry__c' => 'wmll__branch__c',
       'wmll__leadlab4sf_no_of_employees__c' => 'wmll__size__c',
       'wmll__leadlab4sf_annual_revenue__c' => 'wmll__annualrevenue__c',
       'rating' => 'wmll__rating__c',
       'wmll__id__c' => 'wmll__id__c'
   };
    public static final String LeadQueue = 'Lead Queue';
    public static final String CompanyQueue = 'Company Queue';

    public static final String LeadQueueName = 'Lead_Queue';
    public static final String CompanyQueueName = 'Company_Queue';

    public static final String AdminProfileName_DE = 'System Administrator';
    public static final String AdminProfileName_EN = 'Systemadministrator';


    //General webservice information
    public static final String DEFAULT_ENDPOINT = 'https://sfa.wiredminds.de';
    public static final String WM_DATA_RESOURCE = '/app/frontend/WMData.php';
    public static final String WM_SERVICE_RESOURCE = '/app/frontend/WMService.php';

    public static final String PARAM_WEBSITE = 'websitesel';
    public static final String PARAM_METHOD = 'method';
    public static final Integer DEFAULT_BATCH_SIZE = 50;

    public static final String CREATE_TENANT_PART_URI = '/api/v1/customer/create';
    public static final String CUSTOMER_NAME = 'logicline GmbH';
    public static final String CUSTOMER_DOMAIN = 'logicline.de';
    public static final String CUSTOMER = 'customer';
    public static final String NAME = 'name';
    public static final String DOMAIN = 'domain';
    public static final String POST_METHOD = 'POST';
    public static final String APPLICATION_JSON = 'application/json';
    public static final String TEST_PUBLICCUSTNUM = 'abb1f75e9786bc57';
    public static final String TEST_TOKEN = '44a7c87596dbd3b36bba3fa186deee79';
    public static final String PUBLICCUSTNUM = 'publicCustnum';
    public static final String TOKEN = 'token';
    public static final String ORG_ID = 'org_id';
    public static final String ORG_NAME = 'org_name';

    public static final String FROM_TIME = 'fromTime';
    public static final String TO_TIME = 'toTime';
    public static final String START = 'start';
    public static final String LENGTH = 'length';
    public static final String GET_METHOD = 'GET';
    public static final String CUSTOMER_PART_URI = '/api/v1/customer/';
    public static final String COMPANIES_PART_URI = '/companies';
    public static final String LEGAL_FORMS_PART_URI = '/api/v1/legalforms';
    public static final String START_POSITION = 'startPosition';

    public static final Integer START_SCHEDULER_IN_MINUTE = 10;
    public static final Integer START_DEFAULT_FETCH_POSITION = 0;
    public static final Integer DEFAULT_LENGTH_FETCH_PER_REQUEST = 1000;


    //WM_Data params
    public static final String PARAM_GET_COMPANIES = 'companies';
    public static final String PARAM_GET_COMPANIES_EXT = 'companies_extended';
    public static final String PARAM_DATE_FROM = 'date_from';
    public static final String PARAM_DATE_TO = 'date_to';
    public static final String PARAM_MODE = 'mode';
    public static final String PARAM_STARTPOS = 'startpos';
    public static final String PARAM_LENGTH = 'length';
    public static final String PARAM_LANGUAGE = 'language';
    public static final String PARAM_FILTERNAME = 'filtername';
    public static final String PARAM_FILTEROWNER = 'filterowner';
    public static final String PARAM_SCORE_PROFILE_ID = 'score_profile_id';
    public static final String DEFAULT_PARAM_SCORE_PROFILE_ID = '0';

    //WM_Service params
    public static final String PARAM_GET_FILTERS = 'getActiveFiltersXML';

    //custom setting
    public static final String CUSTOM_SETTING_NAME = 'LeadLabSettings';
    public static final String DEFAULT_LEAD_NAME = 'LeadLab Lead';
    //scheduler job
    public static final String SCHEDULER_NAME = 'FetchVisits_ScheduledJob';
    public static final String LEGAL_FORM_SCHEDULER_NAME =
        'FetchLegalForm_ScheduledJob';
    public static final String SCHEDULER_NAME_FETCH_AFTER_CLICK =
        'FetchVisitsScheduler';

    //Batch processing info
    //amount of entries processed per workunit (fetchsize/pagesize of callout)
    public static final Integer WORK_UNIT_SIZE = 75;
    //amout of workunits processed per chunk
    public static final Integer BATCH_SIZE = 2;
    //amount of chunks per batchjob (is calculated automatically by batchable class, but used to calculate static number of pages processed per batch)
    //limit of callouts per batchjob is 10
    public static final Integer CHUNK_AMOUNT = 5;

    public static final Time THE_END_OF_DAY_TIME = Time.newInstance(23, 59, 59, 0);
    public static final Integer soqlLimit = 50000;

    public static final String LEAD_SOURCE_WEB = 'Web';
    public static final String LEAD_SOURCE_PHONE = 'Phone';
    public static final String LEAD_SOURCE_OTHER = 'Other';

    public static final String PROCESSING_AUTOMATIC = 'Automatic';
    public static final String PROCESSING_MANUAL = 'Manual';

    public static final String VISIT_LIMIT_5 = '5';
    public static final String VISIT_LIMIT_10 = '10';
    public static final String VISIT_LIMIT_50 = '50';

    public static final String FETCH_INTERVAL_6AM = '6AM';
    public static final String FETCH_INTERVAL_12H = '12h';
    public static final String FETCH_INTERVAL_2H = '2h';
    public static final String FETCH_INTERVAL_4H = '4h';
    public static final String FETCH_INTERVAL_1H = '1h';

    public static final String COMPANY_MODE = 'Company';
    public static final String LEAD_MODE = 'Lead';
    public static final String ACCOUNT_MODE = 'Account';
}