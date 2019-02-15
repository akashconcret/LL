public with sharing class CompanyCtrl {

    private Logger.IService log = Logger.getDefault(CompanyCtrl.class);

    private SfUtilsLib.IFlsService flsService;

    private String redirectUrl = '/' + WMLL__Company__c.SObjectType.getDescribe().getKeyPrefix();

    // private final ApexPages.StandardController ctrl;

    private List<Visit__c> visits = new List<Visit__c>();

    private Company__c company;
    
    public DMLManager.Result companyNotConverted{get;set;}
    List<DMLManager.CompanyUnableToConvert> companyHavingNoVisits;
    public String backToCompanyUrl{get;set;}
    public String errormsg{get;set;}
    
    public List<Id> lstCompanyIds{get;set;}
     
    public CompanyCtrl(ApexPages.StandardSetController controller) {
        RunOnlyFromManager.executeTrigger();
        lstCompanyIds = new List<Id>();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        backToCompanyUrl = baseUrl+'/'+redirectUrl;
        companyNotConverted = new DMLManager.Result();
        
        for (Company__c cmp : (Company__c[])controller.getSelected() ){
                lstCompanyIds.add(cmp.id);
        }
        
    }
    
    //This method is called automatically when page is loaded.
    //This method helps to examine which object should be created on the basis of url parameter .
    public PageReference createSobjects() {
        this.flsService = SfUtilsLib.getFlsService();
// 		final Id ctrlId = ApexPages.currentPage().getParameters().get('id');
        DescribeSObjectResult ckeckCompanyPermission = CheckPermissionUtility.getDescribeSObjectResult('WMLL__Company__c');
        
		if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('id')) && CheckPermissionUtility.checkAllPermissionsObject(ckeckCompanyPermission)){
            List<Company__c> companies = new List<Company__c>();
            List<string> lstString = new list<string>{'Name','WMLL__BranchWz2008__c','WMLL__Lead_Status__c','WMLL__Rating__c','WMLL__Branch__c','WMLL__City__c','WMLL__CountryCode2__c',
                    'WMLL__CountryName__c','WMLL__Domain__c','WMLL__Email__c','WMLL__Fax__c','WMLL__HouseNumber__c','WMLL__Id__c','WMLL__Phone__c','WMLL__Region__c','WMLL__Size__c',
                    'WMLL__Street__c','WMLL__Zip__c','WMLL__AnnualRevenue__c'
            };
            if(DMLManager.sobjFieldPermission('WMLL__Company__c',lstString)){
                 companies = [Select Id, Name, BranchWz2008__c,Lead_Status__c,Rating__c, Branch__c,
                                                City__c, CountryCode2__c, CountryName__c, Domain__c, Email__c, Fax__c,
                                                HouseNumber__c, Id__c, Phone__c, Region__c, Size__c, Street__c,
                                                Zip__c,AnnualRevenue__c From Company__c Where Id = : ApexPages.currentPage().getParameters().get('id') Limit 1];
            }
            if(companies.isEmpty()){
                errormsg = 'You do not have sufficient permission for Company';
                return null;    
            }
    
            if(companies.size()>0){
                this.company = companies.get(0);
            }
            
            if(!flsService.checkWithMessage(company)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 
                    'Access permission missing, Please contact to Administrator'));
                return null;    
            } 
            for(List<Visit__c> lstVisits : [Select Id, Company__c From Visit__c Where Company__c = : ApexPages.currentPage().getParameters().get('id')]){
                this.visits.addAll(lstVisits);
            }
            //this.visits.addAll([Select Id, Company__c From Visit__c Where Company__c = : ApexPages.currentPage().getParameters().get('id')]);
            if(!flsService.checkWithMessage(visits)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 
                    'Visit update access permission missing, Please contact to Administrator'));
                return null;    
            } 
    
		}    
		
        //in below conditions . It is determined that which method must be called as per url's parameter . 
        if(ApexPages.currentPage().getParameters().get('createSobject')=='lead'){
            return createLead();
        }else if(ApexPages.currentPage().getParameters().get('createSobject')=='account'){
           return createAccount();
        }else if(lstCompanyIds.size()>0){
            return createMassAccount(lstCompanyIds);
        }
        return null; 
    }

    //returns  
    public Pagereference cancel(){
        Pagereference pageref;
        if(lstCompanyIds.size()==0 && this.company != null && DMLManager.getUserTheme()){
            pageref = new Pagereference('/one/one.app#/sObject/'+this.company.id+'/view');
        }else if(lstCompanyIds.size()==0 &&  this.company != null){
            pageref = new Pagereference('/'+this.company.id);
        }
        if(pageref!=null){
            pageref.setRedirect(true);
            return pageref;
        }else{
            return DMLManager.redirectAsPerUserTheme();
        }
    }
    
    //This method returns a map of all visits per company. which needs to be converted either in lead or in account...
    public Map<Company__c,List<Visit__c>> returnVisitsforMassObjectCreation(List<Id> companyIds){  // return company visits
        
        Map<Company__c,List<Visit__c>> mapForCompanyVisits = new Map<Company__c,List<Visit__c>>();
        //for(Company__c company : [Select Id, Name, BranchWz2008__c, Branch__c,Lead_Status__c,Rating__c,
         //                                   City__c, CountryCode2__c, CountryName__c, Domain__c, Email__c, Fax__c,
          //                                  HouseNumber__c, Id__c, Phone__c,AnnualRevenue__c, Region__c, Size__c, Street__c,
          //                                  Zip__c,(Select Id, Company__c From companyVisits__r) From Company__c Where Id = : companyIds]){
        //
                
          //  mapForCompanyVisits.put(company,company.companyVisits__r);
        //}
        
        for(Visit__c visitRecord : [Select Id,Company__c , Company__r.Name, Company__r.BranchWz2008__c, Company__r.Branch__c,Company__r.Lead_Status__c,Company__r.Rating__c,
                                            Company__r.City__c, Company__r.CountryCode2__c, Company__r.CountryName__c, Company__r.Domain__c, Company__r.Email__c, Company__r.Fax__c,
                                            Company__r.HouseNumber__c, Company__r.Id__c, Company__r.Phone__c,Company__r.AnnualRevenue__c, Company__r.Region__c, Company__r.Size__c, Company__r.Street__c,
                                            Company__r.Zip__c From Visit__c Where Visit__c.Company__c = : companyIds limit 50000]){
                                            
                                            Company__c newCompInstance = new Company__c(Id=visitRecord.Company__c);
                                            newCompInstance.Name = visitRecord.Company__r.Name;
                                            newCompInstance.BranchWz2008__c = visitRecord.Company__r.BranchWz2008__c;
                                            newCompInstance.Branch__c = visitRecord.Company__r.Branch__c;
                                                newCompInstance.Lead_Status__c = visitRecord.Company__r.Lead_Status__c;
                                                newCompInstance.Rating__c = visitRecord.Company__r.Rating__c;
                                                newCompInstance.City__c = visitRecord.Company__r.City__c;
                                                newCompInstance.CountryCode2__c = visitRecord.Company__r.CountryCode2__c;
                                                newCompInstance.CountryName__c = visitRecord.Company__r.CountryName__c;
                                                newCompInstance.Domain__c = visitRecord.Company__r.Domain__c;
                                                newCompInstance.Email__c = visitRecord.Company__r.Email__c;
                                                newCompInstance.Fax__c = visitRecord.Company__r.Fax__c;
                                                newCompInstance.HouseNumber__c = visitRecord.Company__r.HouseNumber__c;
                                                newCompInstance.Id__c = visitRecord.Company__r.Id__c;
                                                newCompInstance.Phone__c = visitRecord.Company__r.Phone__c;
                                                newCompInstance.AnnualRevenue__c = visitRecord.Company__r.AnnualRevenue__c;
                                                newCompInstance.Region__c = visitRecord.Company__r.Region__c;
                                                newCompInstance.Size__c = visitRecord.Company__r.Size__c;
                                                newCompInstance.Street__c = visitRecord.Company__r.Street__c;
                                                newCompInstance.Zip__c = visitRecord.Company__r.Zip__c;
                                                
                                                if(mapForCompanyVisits.containsKey(newCompInstance)){
                                                    mapForCompanyVisits.get(newCompInstance).add(visitRecord);
                                                } else{
                                                    mapForCompanyVisits.put(newCompInstance,new List<Visit__c>{visitRecord});
                                                }                          
            //mapForCompanyVisits.put(company,company.companyVisits__r);
        }
        system.debug('mapForCompanyVisits :: '+JSON.serialize(mapForCompanyVisits));
        return mapForCompanyVisits;
    }
    
    //This method returns comma saparated company ids.....
    
    //This method creates multiple Accounts from multiple companies .
    // and delete all companies which are going to be converted to Accounts...
    // and transfer all visits from particular companies to converted Accounts...
    // if any error persists then It is shown on company page.....
    public PageReference createMassAccount(List<Id> companyIds){
        Map<Company__c,Account> mapForCompanyAndAccount = new Map<Company__c,Account>();
        Map<Company__c,List<Visit__c>> mapForCompanyVisits = returnVisitsforMassObjectCreation(companyIds);
        List<Account> newAccFromcompany = new List<Account>();
        List<Visit__c> lstOfVisits = new List<Visit__c>();
        List<String> setOfCompanyFailedToConvert = new List<String>();
        final AccountManager accountManager = new AccountManager();
        
        companyHavingNoVisits = new List<DMLManager.CompanyUnableToConvert>();
        for(Company__c comp : mapForCompanyVisits.keySet()){
            if(mapForCompanyVisits.get(comp).size()>0){
                Account account;
                try{
                    account = accountManager.createAccount(comp);
                    Schema.DescribeSObjectResult r = account.getSObjectType().getDescribe();
                    if(account!=null && !(r.isCreateable() && r.isUpdateable())){
                        errormsg = Label.NotEnoughAccess;
                        return null;
                    }
                    flsService.checkWithException(account);
                    account.Unmerge_Available__c = true;
                }catch (SfUtilsLib.GenericException ex) {
                    errormsg = Label.NotEnoughAccess;
                    return null;
                }
                if(account!=null){
                    newAccFromcompany.add(account);
                    mapForCompanyAndAccount.put(comp,account);
                }
            }else{
                companyHavingNoVisits.add(new DMLManager.CompanyUnableToConvert(comp.Id,comp.name,Label.NoVisitsAvailableToMigtare));
            }
        }
        
        if(newAccFromcompany.size()>0){
            companyNotConverted = DMLManager.upsertMassAsSystem(newAccFromcompany,companyHavingNoVisits.size()); // creating new account from company....
            if(companyHavingNoVisits!=null && companyHavingNoVisits.size()>0){
                //this method adds company having no visit in error table on company page.
                mergeCompanyHavingNoVisitToErrorTable(companyNotConverted,companyHavingNoVisits);
            }
        }else{
            if(companyHavingNoVisits!=null && companyHavingNoVisits.size()>0){
                //this method adds company having no visit in error table on company page.
                mergeCompanyHavingNoVisitToErrorTable(companyNotConverted,companyHavingNoVisits);
            }
        }
        if(mapForCompanyAndAccount.keySet().size()>0){
            for(Company__c comp : mapForCompanyAndAccount.keySet()){
                if(mapForCompanyVisits.containskey(comp)){
                    if(mapForCompanyAndAccount.get(comp).Id!=null){
                        for(Visit__c visit : mapForCompanyVisits.get(comp)){
                            visit.Account__c = mapForCompanyAndAccount.get(comp).Id; //this map will return account.
                            visit.Company__c = null;
                            lstOfVisits.add(visit);
                        }
                    }else if(mapForCompanyAndAccount.get(comp).Id==null){
                        
                        mapForCompanyAndAccount.remove(comp);
                    }
                }
            }
            if(lstOfVisits.size()>0){
                try{
                    DMLManager.updateAsSystem(lstOfVisits);  ////   updating visits under newly created accounts.
                        DMLManager.deleteAsSystem(new List<Company__c>(mapForCompanyAndAccount.keySet()));
                    return null;
                }catch(Exception ee){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,ee.getMessage()));
                }
            }
        }
        return  null;
    }
    
    
    //This method merges the companies which do not have any visits to migrate with the error table shown on company page......
    public DMLManager.Result mergeCompanyHavingNoVisitToErrorTable(DMLManager.Result result,List<DMLManager.CompanyUnableToConvert> compInErrorTable){
        if(compInErrorTable!=null && compInErrorTable.size()>0){
                if(result.lstCompanyUnableToConvert!=null){
                    for(DMLManager.CompanyUnableToConvert compNoVisits : result.lstCompanyUnableToConvert){
                        compInErrorTable.add(compNoVisits);
                    }
                    result.lstCompanyUnableToConvert = compInErrorTable;
                }else{
                    result.lstCompanyUnableToConvert = compInErrorTable;
                }
             return   result; 
        }else{
            return result;
        }
    }
    public  PageReference createLead() {
        if(!visitsAvailableToMigrate(new Lead())) return null;

        if(!flsService.checkWithMessage(this.company)) return null;

        try {
            final Id leadId = transferVisitsToLead();
            if(leadId!=null){
                return deleteCompanyAndRedirect(leadId);
            }else{
                return null;
            }
        } catch (SfUtilsLib.GenericException ex) {
            system.debug('ex::'+ex.getTypeName() + ' - ' + ex.getCause() + ': ' + ex.getMessage());
            errormsg = Label.NotEnoughAccessForLead;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.NotEnoughAccessForLead));
        }
        return null;
    }

    private Id transferVisitsToLead() /* throws SfUtilsLib.AccessVoilationException */ {
        final LeadManager leadManager = new LeadManager();

        final Lead lead = leadManager.createNewLead(this.company);
        lead.Unmerge_Available__c = true;
        // DMLManager.upsertAsSystem(lead);
        companyNotConverted = DMLManager.upsertMassAsSystem(new List<Lead>{lead},0);
        if(companyNotConverted!=null && companyNotConverted.lstCompanyUnableToConvert!=null &&  companyNotConverted.lstCompanyUnableToConvert.size()==0){
            // leadManager.addLeadsToCampaign(new List<Lead>{ lead });
            for(Visit__c visit : visits){
                visit.Company__c = null;
                visit.Lead__c = lead.Id;
            }
            DMLManager.updateAsSystem(this.visits);
            return lead.Id;
        }
        return null;
    }
    // webservice static String massCreateAccount(String companyIds){
    //     system.debug('web:::'+companyIds);
    //     return companyIds;
    // }
    public PageReference createAccount() {
        if(!visitsAvailableToMigrate(new Account())) return null;
        
        final AccountManager accountManager = new AccountManager();
        Account account;
        try{
            account = accountManager.createAccount(this.company);
            account.Unmerge_Available__c = true;
            // checking user permissions for Account.
            flsService.checkWithException(account);
        }catch(SfUtilsLib.GenericException ex){
            // account = null;
            errormsg = Label.NotEnoughAccess;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.NotEnoughAccess));
            return null;
        }
        if(account != null){
            companyNotConverted = DMLManager.upsertMassAsSystem(new List<Account>{account},0);
        }
        if(companyNotConverted!=null && companyNotConverted.lstCompanyUnableToConvert!=null && companyNotConverted.lstCompanyUnableToConvert.size()==0){
            for(Visit__c visit : visits){
            	visit.Account__c = account.Id;
                visit.Company__c = null;
            }
            DMLManager.updateAsSystem(this.visits);
    
            return deleteCompanyAndRedirect(account.Id);
        }else{
            return null;
        }
    }

    private PageReference deleteCompanyAndRedirect(Id objId) {
        final PageReference pageRef = new PageReference('/' + objId);
        pageRef.setRedirect(true);
        // if(!Test.isRunningTest()){ 
            DMLManager.deleteAsSystem(new List<Company__c>{this.company});
        // }
        return pageRef;
    }

    // public PageReference mergeTo() {

    //     if(!visitsAvailableToMigrate(null)) return null;

    //     final PageReference mergePage = Page.CompanyMerge;
    //     mergePage.getParameters().put('Id', this.company.Id);

    //     return mergePage;
    // }

    private Boolean visitsAvailableToMigrate(Sobject sobj) {
        if(this.visits.isEmpty()) {
            if(sobj!=null && sobj.getSObjectType().getDescribe().getName()=='Account'){
                errormsg = Label.NoVisitsAvailableForAccount;
                // ApexPages.addmessage(new ApexPages.Message(
                //                      ApexPages.Severity.Error, Label.NoVisitsAvailableForAccount));
            }else if(sobj!=null && sobj.getSObjectType().getDescribe().getName()=='Lead'){
                errormsg = Label.NoVisitsAvailableToMigtareForLead;
                // ApexPages.addmessage(new ApexPages.Message(
                //                      ApexPages.Severity.Error, Label.NoVisitsAvailableToMigtareForLead));
            }
        }

        return !this.visits.isEmpty();
    }
}