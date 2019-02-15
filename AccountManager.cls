public with sharing class AccountManager {

    private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();
    private final String DEFAULT_RATING = DMLManager.returnDefaultPicklistValue(new Lead(),'Rating') != null?
                                          DMLManager.returnDefaultPicklistValue(new Lead(),'Rating'):'Warm';
    private final Setting__c settings;
    private final Id stdUser;

    public AccountManager() {
        this(Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME));
    }

    public AccountManager(Setting__c settings) {
        this.settings = settings;
        if(settings != null && String.isNotEmpty(settings.StandardTaskUser__c))
            this.stdUser = settings.StandardTaskUser__c;
    }

    public Account createAccount(Company__c company) {
        
        final Account account = new Account();

        if(!flsService.checkWithMessage(company)) return null;
        if(!flsService.checkWithMessage(account)) return null;

        if(this.stdUser != null)
            account.OwnerId = settings.StandardTaskUser__c;

        account.Id__c = company.Id__c;
        account.Name = company.Name;
        account.Rating = !String.isEmpty(company.Rating__c)?
                             company.Rating__c:DEFAULT_RATING;
        
        //Below three fields added for release 2.0 on 05 april 17.    
        account.LeadLab4SF_Annual_Revenue__c = company.AnnualRevenue__c;
        account.LeadLab4SF_No_of_Employees__c = company.Size__c;
        account.LeadLab4SF_Industry__c = company.Branch__c;
        //account.Branch__c = company.Branch__c;
        //account.BranchWz2008__c = company.BranchWz2008__c;
        account.BillingCity = company.City__c;
        account.ShippingCity = company.City__c;
        //account.CountryCode2__c = company.CountryCode2__c;
        account.BillingCountry = company.CountryName__c;
        account.ShippingCountry = company.CountryName__c;
        account.Website = company.Domain__c;
        //account.Email__c = company.Email__c;
        account.Fax = company.Fax__c;
        account.BillingStreet = company.Street__c;
        if(String.isNotEmpty(company.HouseNumber__c))
            account.BillingStreet += ' ' + company.HouseNumber__c;

        account.ShippingStreet = company.Street__c;
        if(String.isNotEmpty(company.HouseNumber__c))
            account.ShippingStreet += ' ' + company.HouseNumber__c;

        account.Phone = company.Phone__c;
        account.BillingState = company.Region__c;
        account.ShippingState = company.Region__c;
        //account.Size__c = company.Size__c;
        account.BillingPostalCode = company.Zip__c;
        account.ShippingPostalCode = company.Zip__c;
        
        
        return account;
    }
}