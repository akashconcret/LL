public with sharing class CompanyMergeCtrl {

    private final Logger.IService log = Logger.getDefault(CompanyMergeCtrl.class);

    private final SfUtilsLib.IFlsService flsService;
    public MetaObject__c metaObj {get; set; }
    public String selectedType {get; set;}
    public List<SelectOption> typeOptions {get; set;}
    public String leadLabId {get; set;}
    public String errorMsg{get;set;}
    
    private Id companyId;
    private final Company__c company;

    public CompanyMergeCtrl(ApexPages.StandardController controller) {
        this(controller, SfUtilslib.getFlsService());
    }

    public CompanyMergeCtrl(ApexPages.StandardController controller, SfUtilsLib.IFlsService flsService) {
        this.companyId = controller.getId();
        this.flsService = flsService;

        this.metaObj = new MetaObject__c();
        this.typeOptions = new List<SelectOption> {
            new SelectOption(Lead.getSObjectType().getDescribe().getName(), Lead.getSObjectType().getDescribe().getName()),
            new SelectOption(Account.getSObjectType().getDescribe().getName(), Account.getSObjectType().getDescribe().getName())
        };
        this.selectedType = this.typeOptions.get(0).getValue();

        if(this.companyId == null)
            errorMsg = Label.PleaseCheckCompany;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PleaseCheckCompany));
        this.company = (Company__c) controller.getRecord();
        // leadLabId = [Select Id__c from Company__c Where Id =: companyId Limit 1].Id__c;
    }

    public Boolean getLeadSelected() {
        return Lead.getSObjectType().getDescribe().getName().equalsIgnoreCase(this.selectedType);
    }

    public Boolean getAccountSelected() {
        return Account.getSObjectType().getDescribe().getName().equalsIgnoreCase(this.selectedType);
    }

    public PageReference doCancel() {
        return new PageReference('/' + company.Id);
    }
    
    public PageReference doMerge() {
        PageReference pgref;
        if(selectedType!=null && selectedType=='Lead' && validSelection()){
            pgref= new PageReference('/apex/CompanyMergeWizard?companyId='+company.Id+'&sObjId='+metaObj.Lead__c);
        }else if(selectedType!=null && selectedType=='Account' && validSelection()){
            pgref= new PageReference('/apex/CompanyMergeWizard?companyId='+company.Id+'&sObjId='+metaObj.Account__c);
        }
        if(pgref!=null){
            pgref.setRedirect(true);
            return pgref;
        }
        return null;
    }
    // public PageReference doMerge() {
    //     final List<Visit__c> visitsForMerge = [SELECT Account__c, Lead__c, Company__c
    //                                           FROM Visit__c WHERE Company__c = :company.Id];
    //     if(!flsService.checkWithMessage(visitsForMerge)) return null;
        
    //     log.debug('Attemping to merge visits: ', visitsForMerge);
    //     if(this.selectedType == Lead.getSObjectType().getDescribe().getName()) {

    //         final PageReference page = mergeToLead(visitsForMerge);
    //         if(page == null) return page;

    //         DMLManager.deleteAsSystem(new list<company__c>{this.company});
    //         return page;
    //     } else if(this.selectedType == Account.getSObjectType().getDescribe().getName()) {
    //         final PageReference page = mergeToAccount(visitsForMerge);
    //         if(page == null) return page;

    //         DMLManager.deleteAsSystem(new list<company__c>{this.company});
    //         return page;
    //     }

    //     return null;
    // }

    // private PageReference mergeToLead(List<Visit__c> visits) {
    //     if(!validSelection()) return null;

    //     final Lead lead = [Select Id From Lead Where Id = : this.metaObj.Lead__c];
    //     if(!flsService.checkWithMessage(lead)) return null;
        
    //     if(visits.size()>0){
    //         lead.Id__c = leadLabId;
    //         DMLManager.updateAsSystem(lead);
            
    //         for(Visit__c visit : visits){
    //             visit.Lead__c = lead.Id;
    //             visit.Company__c = null;
    //         }
    //         DMLManager.updateAsSystem(visits);
    
    //         final PageReference leadPage = new PageReference('/' + lead.Id);
    //         leadPage.setRedirect(true);
    //         return leadPage;
    //     }else{
    //         errorMsg = Label.NoVisitsToMerge;
    //         // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.NoVisitsToMerge));
    //         return null;
    //     }
    // }

    // private PageReference mergeToAccount(List<Visit__c> visits) {
    //     if(!validSelection()) return null;

 
    //     final Account account = [Select Id From Account Where Id = : this.metaObj.Account__c];
    //     if(!flsService.checkWithMessage(account)) return null;

    //     if(visits.size()>0){
    //         account.Id__c = leadLabId;
    //         DMLManager.updateAsSystem(account);
            
    //         for(Visit__c visit : visits){
    //             visit.Account__c = account.Id;
    //             visit.Company__c = null;
    //         }
    //         DMLManager.updateAsSystem(visits);
    
    //         final PageReference acountPage = new PageReference('/' + account.Id);
    //         acountPage.setRedirect(true);
    //         return acountPage;
    //     }else{
    //         errorMsg = Label.NoVisitsToMerge;
    //         // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.NoVisitsToMerge));
    //         return null;
    //     }
    // }

    private Boolean validSelection() {
        final Boolean valid = !(String.isEmpty(this.metaObj.Account__c) && String.isEmpty(this.metaObj.Lead__c));
        if(!valid){
            errorMsg = Label.Merge_NothingSelected;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Merge_NothingSelected)); 
        }
           
                
        System.debug(valid);

        return valid;
    }
}