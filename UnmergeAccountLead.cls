//In this class we unmerge a lead/Account to company.
//This class is invoked from  from Unmerge button from lead's/Account's  detail page .

public with sharing class UnmergeAccountLead {
   private static final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();
   public Id sobjId{get;set;}
   public String error{get;set;}
   public String backToSobject{get;set;}
   public Wmll__company__c comp{get;set;}
   public UnmergeAccountLead(){
       RunOnlyFromManager.executeTrigger();
      sobjId = Apexpages.currentpage().getparameters().get('Id'); 
   }
   //This method is called when Page loads. Here we find out the sobject(Account/Lead) to unmerge.
   public Pagereference doMerge(){
       String haveCompanyIdAfterUnmerge;
       Pagereference pageref;
       if(sobjId!=null && sobjId.getSobjectType().getDescribe().getName() == 'Lead'){
          backToSobject = Label.BackToSobject.replace('Account','Lead');
           haveCompanyIdAfterUnmerge = mergeLead(new List<Id>{sobjId});
           pageref = new Pagereference('/'+haveCompanyIdAfterUnmerge);
           pageref.setRedirect(true);
       }
       if(sobjId!=null && sobjId.getSobjectType().getDescribe().getName() == 'Account'){
          backToSobject = Label.BackToSobject;
           haveCompanyIdAfterUnmerge = mergeAccount(new List<Id>{sobjId});
           pageref = new Pagereference('/'+haveCompanyIdAfterUnmerge);
           pageref.setRedirect(true);
       }
       if(haveCompanyIdAfterUnmerge==null){
           return null;
       }
       return pageref;
   }
   public Pagereference backToSobject(){
       Pagereference pageref = new Pagereference('/'+sobjId);
       pageref.setRedirect(true);
       return pageref;
   }
   //This method Unmerege the selected Account.
   // Field Values to the newly created company is given from Account in this method.
   public string mergeAccount(List<Id> accId) {
       DescribeSObjectResult ckeckAccPermission = CheckPermissionUtility.getDescribeSObjectResult('Account');
        List<string> lstAccFields = new List<string>{
            'Wmll__Unmerge_Available__c',
            'Wmll__Id__c',
            'Name',
            'Rating',
            'Wmll__LeadLab4SF_Annual_Revenue__c',
            'Wmll__LeadLab4SF_No_of_Employees__c',
            'Wmll__LeadLab4SF_Industry__c',
            'BillingCity',
            'ShippingCity',
            'BillingCountry',
            'ShippingCountry',
            'Website',
            'Fax',
            'BillingStreet',
            'ShippingStreet',
            'Phone',
            'BillingState',
            'BillingPostalCode',
            'ShippingPostalCode'
        };
        
        if(DMLManager.sobjFieldPermission('Account',lstAccFields)){
            Account acc = [select OwnerId,Wmll__Unmerge_Available__c,Wmll__Id__c,Name,Rating,Wmll__LeadLab4SF_Annual_Revenue__c,Wmll__LeadLab4SF_No_of_Employees__c,Wmll__LeadLab4SF_Industry__c
                            ,BillingCity,ShippingCity,BillingCountry,ShippingCountry,Website,Fax,BillingStreet,ShippingStreet
                            ,Phone,BillingState,ShippingState,BillingPostalCode,ShippingPostalCode from Account where id =:accId[0]];
        
        
            // flsService.checkWithException(acc);
            List<Wmll__visit__c> lstOfVisits = [select Wmll__company__c,Wmll__account__c,Wmll__lead__c from Wmll__visit__c where Wmll__account__c =:accId[0]];
             comp = new Wmll__company__c();                   
            if(acc!=null && acc.Wmll__Unmerge_Available__c == true){
                comp.name = acc.Name;
                comp.Wmll__id__c = acc.Wmll__Id__c;
                acc.Wmll__Id__c = null;
                comp.Wmll__rating__c = acc.Rating;
                comp.Wmll__annualrevenue__c = acc.Wmll__LeadLab4SF_Annual_Revenue__c;
                acc.Wmll__LeadLab4SF_Annual_Revenue__c = null;
                comp.Wmll__size__c = acc.Wmll__LeadLab4SF_No_of_Employees__c;
                acc.Wmll__LeadLab4SF_No_of_Employees__c = null;
                comp.Wmll__branch__c = acc.Wmll__LeadLab4SF_Industry__c;
                acc.Wmll__LeadLab4SF_Industry__c=null;
                comp.Wmll__city__c = acc.BillingCity;
                comp.Wmll__countryname__c = acc.BillingCountry;
                comp.Wmll__domain__c = acc.Website;
                comp.Wmll__fax__c = acc.Fax;
                comp.Wmll__street__c = acc.BillingStreet;
                comp.Wmll__phone__c = acc.Phone;
                comp.Wmll__region__c = acc.BillingState;
                comp.Wmll__zip__c = acc.BillingPostalCode;
                comp.Wmll__lead_status__c = 'Open';
                acc.Wmll__Unmerge_Available__c = false;
                return manipulateSobjects(new List<SObject>{comp},new List<SObject>{acc},lstOfVisits);
            }else{
                error = Label.AccountUnmerge;
                return null;
            }
            // flsService.checkWithException(comp);
        }else{
            // error
            error = 'You do not have enough permission.';
            return null;
        }
    }
    // this method migrates visits from Account/lead to newly created company or updated company.
    public  void migrateVisits(List<Id> compId,List<Wmll__Visit__c> visits){
        if(visits!=null && compId[0]!=null && visits.size()>0){
            for(Wmll__Visit__c vis : visits){
                vis.Wmll__company__c = compId[0];
                vis.Wmll__account__c = null;
                vis.Wmll__lead__c = null;
            }
            if(visits[0].getSObjectType().getDescribe().isupdateable()){
                update visits;
            }
        }
    }
    // this method unmerge a lead to company.
    public string mergeLead(List<Id> leadId) {
        DescribeSObjectResult ckeckLeadPermission = CheckPermissionUtility.getDescribeSObjectResult('Lead');
        
        List<string> lstLeadFields = new List<string>{
            'Status',
            'Wmll__Unmerge_Available__c',
            'Rating',
            'LeadSource',
            'Wmll__ID__c',
            'Company',
            'Wmll__LeadLab4SF_Industry__c',
            'Wmll__LeadLab4SF_Annual_Revenue__c',
            'Website',
            'Email',
            'street',
            'Wmll__LeadLab4SF_No_of_Employees__c',
            'Phone',
            'City',
            'State',
            'Country',
            'PostalCode'
        };
        
        if(DMLManager.sobjFieldPermission('Lead',lstLeadFields)){
            Lead ld =  [select Status,Wmll__Unmerge_Available__c,Rating,LastName,LeadSource,OwnerId,Wmll__ID__c,Company,Wmll__LeadLab4SF_Industry__c,Wmll__LeadLab4SF_Annual_Revenue__c
                        ,Website,Email,street,Wmll__LeadLab4SF_No_of_Employees__c,Phone,City,State,Country,PostalCode from Lead where Id =:leadId[0]];
        
        
        
            // flsService.checkWithException(ld);
            List<Wmll__visit__c> lstOfVisits = [select Wmll__company__c,Wmll__lead__c,Wmll__account__c from Wmll__visit__c where Wmll__lead__c =:leadId[0]];
            comp = new Wmll__company__c(); 
            if(ld!=null && ld.Wmll__Unmerge_Available__c == true){
                comp.name = ld.Company;
                comp.Wmll__lead_status__c = ld.Status;
                comp.Wmll__id__c = ld.Wmll__ID__c;
                ld.Wmll__ID__c = null;
                comp.Wmll__rating__c = ld.Rating;
                comp.Wmll__annualrevenue__c = ld.Wmll__LeadLab4SF_Annual_Revenue__c;
                ld.Wmll__LeadLab4SF_Annual_Revenue__c = null;
                comp.Wmll__branch__c = ld.Wmll__LeadLab4SF_Industry__c;
                ld.Wmll__LeadLab4SF_Industry__c = null;
                comp.Wmll__city__c = ld.City;
                comp.Wmll__Street__c = ld.street;
                comp.Wmll__Size__c = ld.LeadLab4SF_No_of_Employees__c;
                comp.Wmll__countryname__c = ld.Country;
                comp.Wmll__domain__c = ld.Website;
                comp.Wmll__phone__c = ld.Phone;
                comp.Wmll__region__c = ld.State;
                comp.Wmll__zip__c = ld.PostalCode;
                ld.Wmll__Unmerge_Available__c = false;
                
                return manipulateSobjects(new List<SObject>{comp},new List<SObject>{ld},lstOfVisits);
            }else {
                error = Label.LeadUnmerge;
                return null;
            }
            // flsService.checkWithException(comp);
        }else{
            error = 'You do not have enough permission.';
            return null;
        }
    }
    
    // here , we are updating Company , Lead/Account and migrating visits to company.
    public string manipulateSobjects(List<Sobject> sobjCompany,List<Sobject> sObj,List<Sobject> listOfVisits){
        Savepoint sp = Database.setSavepoint();
        try{
            if(sobjCompany[0].getSObjectType().getDescribe().isCreateable()){
                upsert (Company__c) sobjCompany[0] Wmll__Id__c;
                
                migrateVisits(new List<Id>{sobjCompany[0].id},listOfVisits);
                if(sObj[0].getSObjectType().getDescribe().isupdateable()){
                    // update sObj;
                    error = updateUnMergedSObject(sObj);
                }
            }
        }catch(Exception ee){
            // Database.rollback(sp);
        }
        if(sobjCompany[0].get('id')!=null && error==null){
            return (string)sobjCompany[0].get('id');
        }else{
            return null;
        }
    }
    //This method updates Account/Lead( only updates Api Fields) after unmerge.
    // If there is an error then these errors are shown on related vf page.
    public String updateUnMergedSObject(List<Sobject> objList){
        Schema.DescribeSObjectResult r = objList[0].getSObjectType().getDescribe();
        String objName = r.getName();
        Set<String> RequiredField = new Set<String>();
        Integer objListSize = -1;
        if (r.isUpdateable()){
            Database.SaveResult cr = Database.Update(objList[0], false);
                if(cr.isSuccess()){
                }else{
                    for(Database.Error err : cr.getErrors()) {
                        if(err.getFields().size()>0){
                            for(String str : err.getFields()){
                                RequiredField.add(str);
                            }
                        }
                        if(String.valueof(err.getStatusCode()).contains('CUSTOM_VALIDATION_EXCEPTION') ){
                            if(objName=='Account'){
                                return String.valueof(label.AccountUnmergeValidation+ ': ' + err.getMessage());
                            }else{
                                return String.valueof(label.LeadUnmergeValidation+ ': ' + err.getMessage());
                            }
                        }else if(String.valueof(err.getStatusCode()).contains('REQUIRED_FIELD_MISSING')){
                            if(RequiredField.size()==1){
                                if(objName=='Account'){
                                    return String.valueof(label.AccountUnMergeFieldValidation).replace('[Validation]',String.join(new List<String>(RequiredField),','));
                                }else{
                                    return String.valueof(label.AccountUnMergeFieldValidation).replace('Account','Lead').replace('[Validation]',String.join(new List<String>(RequiredField),','));
                                }
                            }else if(RequiredField.size()>1){
                                if(objName=='Account'){
                                    return String.valueof(label.AccountUnMergeFieldValidationM).replace('[Validation]',String.join(new List<String>(RequiredField),','));
                                }else{
                                    return String.valueof(label.AccountUnMergeFieldValidationM).replace('Account','Lead').replace('[Validation]',String.join(new List<String>(RequiredField),','));
                                }
                            }
                        }else if(String.valueof(err.getStatusCode()).contains('DUPLICATE_VALUE')){
                            if(objName=='Account'){
                                return String.valueof(label.DuplicateUnMergeError.replace('[Duplicate]',err.getMessage().replace('duplicate value found','').split(' ').get(1)));
                            }else{
                               return String.valueof(label.DuplicateUnMergeError.replace('Account','Lead').replace('[Duplicate]',err.getMessage().replace('duplicate value found','').split(' ').get(1)));
                            }
                        }else{
                            return String.valueof(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            return null;
        }else{
            return null;
            // return (objName=='Account'?String.valueof(Label.NotEnoughAccessToMerge).replace('[SOBJECT]','Account'):String.valueof(Label.NotEnoughAccessToMerge).replace('[SOBJECT]','Lead'));
        }
    }
}