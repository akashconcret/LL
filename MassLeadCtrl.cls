public with sharing class MassLeadCtrl {
    private Logger.IService log = Logger.getDefault(CompanyCtrl.class);

    private SfUtilsLib.IFlsService flsService;

    private String redirectUrl = '/' + WMLL__Company__c.SObjectType.getDescribe().getKeyPrefix();
    // private final ApexPages.StandardController ctrl;

    private List<Visit__c> visits = new List<Visit__c>();

    private Company__c company;
    private List<Company__c> selectedCompanies;

    private Boolean mandatoryFieldsConfigured;
    
    public DMLManager.Result companyNotConverted{get;set;}
    List<DMLManager.CompanyUnableToConvert> companyHavingNoVisits;
    public String backToCompanyUrl{get;set;}
    public String errormsg{get;set;}
    
    public List<Id> lstCompanyIds{get;set;}
    public MassLeadCtrl(ApexPages.StandardSetController controller) {
        RunOnlyFromManager.executeTrigger();
        lstCompanyIds = new List<Id>();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        backToCompanyUrl = baseUrl+'/'+redirectUrl;
        companyNotConverted = new DMLManager.Result();
        
        for (Company__c cmp : (Company__c[])controller.getSelected() ){
                lstCompanyIds.add(cmp.id);
        }
        if(lstCompanyIds.size()>0){
            
        }
    }
    
    
    public Pagereference cancel(){
      return DMLManager.redirectAsPerUserTheme();
    }
    
    //This method returns a map of all visits per company. which needs to be converted either in lead or in account...
    public Map<Company__c,List<Visit__c>> returnVisitsforMassObjectCreation(List<Id> companyIds){  // return company visits
        Map<Company__c,List<Visit__c>> mapForCompanyVisits = new Map<Company__c,List<Visit__c>>();
        for(Company__c company : [Select Id, Name, BranchWz2008__c, Branch__c,Lead_Status__c,Rating__c,
                                            City__c, CountryCode2__c, CountryName__c, Domain__c, Email__c, Fax__c,
                                            HouseNumber__c, Id__c, Phone__c,AnnualRevenue__c, Region__c, Size__c, Street__c,
                                            Zip__c,(Select Id, Company__c From companyVisits__r) From Company__c Where Id = : companyIds]){
        
                
            mapForCompanyVisits.put(company,company.companyVisits__r);
        }
        
        return mapForCompanyVisits;
    }
    //This method creates multiple lead from multiple companies .
    // and delete all companies which are going to be converted to leads...
    // and transfer all visits from particular companies to converted leads...
    // if any error persists then It is shown on company page.....
    public PageReference createMassLead(){
        Map<Company__c,lead> mapForCompanyAndLead = new Map<Company__c,lead>();
        Map<Company__c,List<Visit__c>> mapForCompanyVisits = returnVisitsforMassObjectCreation(lstCompanyIds);
        List<Lead> newLeadFromcompany = new List<Lead>();
        List<Visit__c> lstOfVisits = new List<Visit__c>();
        List<String> setOfCompanyFailedToConvert = new List<String>();
        final LeadManager leadManager = new LeadManager();
        
        companyHavingNoVisits = new List<DMLManager.CompanyUnableToConvert>();// this list holds company with no visits..
        //in this for loop we saparate , company with visits and company without visits...
        for(Company__c comp : mapForCompanyVisits.keySet()){
            if(mapForCompanyVisits.get(comp).size()>0){
                lead newLead;
                try{
                    newLead = leadManager.createNewLead(comp);
                    Schema.DescribeSObjectResult r = newLead.getSObjectType().getDescribe();
                    if(newLead!=null && !(r.isCreateable() && r.isUpdateable())){
                        errormsg = string.valueOf(Label.NotEnoughAccess).replace('Account','Lead');
                        return null;
                    }
                    newLead.Unmerge_Available__c = true;
                }catch (SfUtilsLib.GenericException ex) {
                    errormsg = Label.NotEnoughAccessForLead;
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.NotEnoughAccessForLead));
                    return null;
                }
                if(newLead!=null){
                    newLeadFromcompany.add(newLead);
                    mapForCompanyAndLead.put(comp,newLead);
                }
            }else{
                companyHavingNoVisits.add(new DMLManager.CompanyUnableToConvert(comp.Id,comp.name,Label.NoVisitsAvailable));
            }
        }
        if(newLeadFromcompany.size()>0){
            companyNotConverted= DMLManager.upsertMassAsSystem(newLeadFromcompany,companyHavingNoVisits.size()); // creating new account from company....
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
        if(mapForCompanyAndLead.keySet().size()>0){
            // in this for loop, we eliminate the company from map mapForCompanyAndLead
            //   which could not be converted to lead by any reason...
            for(Company__c comp : mapForCompanyAndLead.keySet()){
                if(mapForCompanyVisits.containskey(comp)){
                   if(mapForCompanyAndLead.get(comp).Id!=null){
                        for(Visit__c visit : mapForCompanyVisits.get(comp)){
                            visit.Lead__c = mapForCompanyAndLead.get(comp).Id; //this map will return Lead.
                            visit.Company__c = null;
                            lstOfVisits.add(visit);
                        }
                   }else if(mapForCompanyAndLead.get(comp).Id==null){
                       mapForCompanyAndLead.remove(comp);
                   }
                }
            }
            if(lstOfVisits.size()>0){
                try{
                    DMLManager.updateAsSystem(lstOfVisits);  ////   updating visits under newly created accounts.
                    // deleting companies after successfully converting to leads...
                    DMLManager.deleteAsSystem(new List<Company__c>(mapForCompanyAndLead.keySet()));
                    
                    // Assigning newly created lead to a selected campaign.
                    // if(mapForCompanyAndLead!=null && mapForCompanyAndLead.values().size()>0){
                    //     leadManager.addLeadsToCampaign(mapForCompanyAndLead.values());
                    // }
                    return null;
                }catch(Exception ee){
                    // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,ee.getMessage()));
                    return null;
                }
            }
        }
        return null;
    }
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
}