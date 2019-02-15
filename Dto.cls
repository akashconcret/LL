public with sharing class Dto {

    public class LoginResponse {
        public Integer code;
        public Long ts;
        public LoginInformation data;
    }

    public class LoginInformation {
        public String publicCustnum;
        public String token;
        public String enabled;
        public String name;
        public String domain;
        public String packageName;
        public String source;
        public String mode;
        public String pages;
        public String milestones;
        public String campaigns;
        public String pisLimit;
        public String trackingCode;
        public Map<String, String> optOutCodes;
    }

    public class LegalFormData {
        public List<LegalForm> data;
        public String code;
        public Integer ts;
    }

    public class LegalForm {
        public String legalForm;
        public String cc2;
        public String fastMatch;
        public String reversedFastMatch;
        public Integer length;
    }


    public class CompanyResponse {
        public Integer code;
        public Long ts;
        public CompanyData data;
    }

    public class CompanyData {
        public String publicCustnum;
        public Long lastUpdate;
        public Long lastRequest;
        public Integer pisCurrent;
        public Integer detectedCompanies;
        public Boolean limitReached;
        public Long fromTime;
        public long toTime;
        public Integer start;
        public Integer length;
        public Integer resultSize;
        public Boolean hasMore;
        public List<Company> companies;
    }

    public class Company {
        public String id;
        public String name;
        public String domain;
        public String street;
        public String houseNumber;
        public String zip;
        public String city;
        public String region;
        public String countryCode2;
        public String countryName;
        public String phone;
        public String fax;
        public String email;
        public String branch;
        public String branchWz2008;
        public String size; 
        public String revenue;
        public integer duration;
        public Long ddate;
        public Integer pis;
        public String searchPhrases;
        public String userId;
        public String cdId;
        public List<WebPage> pages;
        public List<Referrer> referrers;
        public List<Campaign> campaigns;
        public List<Milestone> milestones;
    }

    public class WebPage {
        public String name;
        public Integer pis;
    }

    public class Referrer {
        public String url;
        public Integer count;
    }

    public class Milestone {
        public String name;
        public Integer count;
    }

    public class Campaign {
        public String name;
        public Integer count;
    }




    public class Customer {
        public String publicCustnum;
        public Boolean enabled = false;
        public Long createDate;
        public Long lastUpdate;
        public Long lastRequest;
        public String name;
        public String domain;
        public String packageName;
        public String source;
        public String mode;
        public Boolean searchPhrases;
        public Boolean referrers;
        public Boolean pages;
        public Boolean milestones;
        public Boolean campaigns;
        public Integer pisLimit = 0;
        public Integer pisCurrent = 0;
        public Integer detectedCompanies = 0;
        public String trackingCode = '';
        public clsOptOutCodes optOutCodes;
    }
    
    public class clsOptOutCodes{
        public String de;
        public String en;
    }
    
    public class CustomerData {
        public Customer data;
        public String code;
        public Integer ts;
    }

    public class TechnicalUser {
        public String username;
        public String password;
        public Map<String, String> customer;
    }


    //public class Company {
    //  public String id;
    //  public String name;
    //  public String domain;
    //  public String street;
    //  public String houseNumber;
    //  public String zip;
    //  public String city;
    //  public String region;
    //  public String countryCode2;
    //  public String countryName;
    //  public String phone;
    //  public String fax;
    //  public String email;
    //  public String branch;
    //  public Integer branchWz2008;
    //  public String size;
    //  public Long lastVisitDate; // date is reserved
    //  public Integer pis;
    //  public String searchPhrases;
    //  public List<Referrer> referrers;
    //  public List<WebPage> pages;
    //  public List<Milestone> milestones;
    //  public List<Campaign> campaigns;
    //  public String userId;
    //  public String cdId;
    //}

    //public class Companies {
    //    public String publicCustnum;
    //    public Long lastUpdate;
    //    public Long lastRequest;
    //    public Integer pisCurrent;
    //    public Integer detectedCompanies;
    //    public Boolean limitReached;
    //    public Long fromTime;
    //    public Long toTime;
    //    public Integer start;
    //    public Integer length;
    //    public Integer resultSize;
    //    public Boolean hasMore;
    //    public List<Company> companies;
    //}

    //public class CompanyData {
    //  public Companies data;
    //  public String code;
    //  public Integer ts;
    //}

    //public class LegalFormData {
    //  public List<LegalForm> data;
    //  public String code;
    //  public Integer ts;
    //}

    //public class LegalForm {
    //  public String legalForm;
    //  public String cc2;
    //  public String fastMatch;
    //  public String reversedFastMatch;
    //  public Integer length;
    //}

}