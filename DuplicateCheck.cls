//This class find the dupicate records(in Account/Lead) for a company and show them in an inline 
//VF page on company's detail page section. 
// in that inline page, clicking on merge button for lead/account. A Vf page is loaded as "DuplicateCheckOnCompany".and It invokes this class. 
// This class is also invoked when click on any company's record to view detail page because of an inline VF Page that shows possible duplicates. 

public with sharing class DuplicateCheck {
   private SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();
   public List<ShowMergeFieldWizard> mergeWizard{get;set;}
   public String duplicateRecordsCount{get;set;}
   public ExtractDuplicate dupLeadAccount {get;set;}
   String recordId;
   public Company__c comp{get;set;}
   public Static List<Visit__c> lstVisits{get;set;}
   public Id companyId{get;set;}
   public Id selectedSobjectId{get;set;}
   public String redirectUrl{get;set;}
   public SObject   CompanyRecordWhenMerged{get;set;}
   public SObject    sObjRecordWhenMerged;
   public String objType{get;set;}
   public String selectedMode{get;set;}
   public Boolean isLightningExperience{get;set;}
   
   //map that holds fields mapping between company and lead.
   public Map<String,String> companyLeadMap = Constants.companyLeadMap;
   //map that holds fields mapping between company and account.
   public Map<String,String> companyAccountMap = Constants.companyAccountMap;
   public string errormsg{get;set;}

    // in constructor , we specify a company Id and lead/Account id from Url.
    // executes when user clicks on merge button from inline vf page on company's detail page.
   public DuplicateCheck(){
       RunOnlyFromManager.executeTrigger();
       mergeWizard = new List<ShowMergeFieldWizard>();
       redirectUrl = '/' + wmll__company__c.SObjectType.getDescribe().getKeyPrefix() + '/o';
       companyId = apexpages.currentpage().getparameters().get('companyId');
       selectedSobjectId = apexpages.currentpage().getparameters().get('sObjId');
       lstVisits = new List<Visit__c>();
       if(selectedSobjectId!=null){
           selectedMode = selectedSobjectId.getSobjectType().getDescribe().getName();
       }
       if(companyId!=null){
           returnCompanyRecords(companyId);
       }
       if(selectedSobjectId!=null){
           returnDupSObjectRecord(selectedSobjectId);
       }
       if(companyId!=null && selectedSobjectId!=null){
           showMappedFields();
       }
   }
   
   
   
// executes when class called from inline vf page on company's detail page to show duplicate records.
   public  DuplicateCheck(ApexPages.standardController controller){
       dupLeadAccount = new ExtractDuplicate();
       recordId = controller.getId();
       if(recordId!=null){
           checkDuplicateRecords(controller.getRecord());
       }
       isLightningInterface();
   }
   
   // This method checks for User Theme.
   public void isLightningInterface(){
       isLightningExperience = DMLManager.getUserTheme();
   }
   //it will return possible fuzzy match for Company Name.
   public list<string> possibleFuzzyMatchForCompanyName(string companyName){
       list<string> listOfSplitedCompanyName = companyName.split(' ');
       list<string> listOfPossibleFuzzyMatch = new list<string>();
       string companySplittedName ='';
       for(string str : listOfSplitedCompanyName){
           if(companySplittedName ==''){
               companySplittedName+=str;
           }else{
               companySplittedName+=' '+str;
           }
           listOfPossibleFuzzyMatch.add(companySplittedName);
       }
       return listOfPossibleFuzzyMatch;
   }
   
  //method extracts possible duplicate for a company by name and any one of company's address field 
  // combination  found in Account/Lead.
   public void checkDuplicateRecords(SObject objectName){
       list<string> possibleFuzzyMatch;
       Schema.sObjectType sobjectType = objectName.getSObjectType();
       Schema.DescribeSObjectResult schemaResult = sobjectType.getDescribe();
       String objcType = schemaResult.getName();
          List<string> lstStr = new List<string>{'WMLL__Zip__c','WMLL__City__c','WMLL__Street__c'};
          
          String query = 'select id,Name,Zip__c,City__c,Street__c from '+objcType+' where id =: recordId';
          
          if(query != null && CheckPermissionUtility.checkSomePermissionsObject(schemaResult) && DMLManager.sobjFieldPermission('WMLL__Company__c',lstStr)){
                comp  =(Company__c) database.query(query)[0];
          }
          if(comp!=null){
              possibleFuzzyMatch = possibleFuzzyMatchForCompanyName(comp.Name);
          }
          
          if(comp != null && possibleFuzzyMatch!=null && possibleFuzzyMatch.size()>0){
              dupLeadAccount.lstOfAcc.addAll([select id,Name,OwnerId,Owner.Name from Account where (((Name IN: possibleFuzzyMatch AND BillingCity =: comp.City__c AND BillingCity!=null) OR (Name IN: possibleFuzzyMatch AND BillingPostalCode =: comp.Zip__c AND BillingPostalCode!=null) OR (Name IN: possibleFuzzyMatch AND BillingStreet =: comp.Street__c AND BillingStreet!=null)))]); 
              dupLeadAccount.lstOfLead.addAll([select id,LastName,Company,Email,OwnerId,Owner.Name from Lead where ((IsConverted=false) AND (((LastName IN: possibleFuzzyMatch OR company IN: possibleFuzzyMatch) AND City =: comp.City__c AND City != null) OR ((LastName IN: possibleFuzzyMatch OR company IN: possibleFuzzyMatch) AND PostalCode =: comp.Zip__c AND PostalCode!=null) OR ((LastName IN: possibleFuzzyMatch OR company IN: possibleFuzzyMatch) AND Street =: comp.Street__c AND Street!=null)))]);
              if(dupLeadAccount.lstOfAcc.size()+dupLeadAccount.lstOfLead.size()==1){
                  duplicateRecordsCount = label.Duplicate_Check_Title.replace('X ',String.valueof((dupLeadAccount.lstOfAcc.size()+dupLeadAccount.lstOfLead.size())+' '));
              }else if(dupLeadAccount.lstOfAcc.size()+dupLeadAccount.lstOfLead.size()>1){
                  duplicateRecordsCount = label.Duplicate_Check_Title_For_Multiple_Reocrds.replace('X ',String.valueof((dupLeadAccount.lstOfAcc.size()+dupLeadAccount.lstOfLead.size())+' '));
              }
          }
   }
   //wrapper class that holds possible duplicate of an company in Leads/Accounts. 
   public class ExtractDuplicate{
       public List<Account> lstOfAcc {get;set;}
       public List<Lead> lstOfLead {get;set;}
       public ExtractDuplicate(){
           lstOfAcc = new List<Account>();
           lstOfLead = new List<Lead>();
       }
   }
   //Merge Wizard Related Code:: 
   //This method constructs the wrapper that display data on vf page and Radio Buttons
   public void showMappedFields(){   
        Set<String> setOfApiNameComp = companyId.getSObjectType().getDescribe().fields.getMap().keySet();
        Schema.DescribeSObjectResult schemaResultsObj = selectedSobjectId.getSObjectType().getDescribe();
        Set<String> setOfApiNameSobj = schemaResultsObj.fields.getMap().keySet();
        objType = schemaResultsObj.getName();
        
        if(objType.equals('Account') ){
            populateSobjectsFieldValue(companyAccountMap,setOfApiNameComp,setOfApiNameSobj,mergeWizard);
        }else if(objType.equals('Lead')){
            populateSobjectsFieldValue(companyLeadMap,setOfApiNameComp,setOfApiNameSobj,mergeWizard);
        }
   }
   
   //this method contructs a wrapper class which holds company and Lead/Account mapped fields
   //   and their value with radio buttons .
  public void populateSobjectsFieldValue(Map<String,String> sObjectFieldMapping,Set<String> companyApiName,Set<String> sObjectApiName,List<ShowMergeFieldWizard> wrapper) {
       Map<String,String> mapHoldsCompApiNameLabel = returnMapForApiNameLabel(companyId.getSObjectType().getDescribe().fields.getMap());
       Map<String,String> mapHoldsSobjectApiNameLabel = returnMapForApiNameLabel(selectedSobjectId.getSObjectType().getDescribe().fields.getMap());
        
        if(mapHoldsSobjectApiNameLabel != null && companyAccountMap != null && sObjectFieldMapping != null){
            for(String str : sObjectFieldMapping.keySet()){
              if(sObjectApiName.contains(str) && CompanyRecordWhenMerged!=null && sObjRecordWhenMerged!=null){
                  if(companyApiName.contains(String.valueof(sObjectFieldMapping.get(str)))){
                      wrapper.add(new ShowMergeFieldWizard(new CompanyRecord(sObjectFieldMapping.get(str),mapHoldsCompApiNameLabel.get(sObjectFieldMapping.get(str)),String.valueof(CompanyRecordWhenMerged.get(sObjectFieldMapping.get(str).toLowerCase()))),
                                     new SObjectRecord(str,mapHoldsSobjectApiNameLabel.get(str),String.valueof(sObjRecordWhenMerged.get(str.toLowerCase()))),'Company'));
                  }
              }
            }
        }
  }
//   This method returns a map that holds ApiNames and Labels Paring For An Object.
  public Map<String,String> returnMapForApiNameLabel(Map<String,Schema.SObjectField> mapOfSobjectFieldDescription){
      Map<String,String> fieldApiNameLabel = new Map<String,String>();
          for(String apiName : mapOfSobjectFieldDescription.keySet()){
              Schema.SObjectField field = mapOfSobjectFieldDescription.get(apiName);
              Schema.DescribeFieldResult F = field.getDescribe();
              fieldApiNameLabel.put(apiName,String.valueof(F.getLabel()));
          }
          return fieldApiNameLabel;
  }
//   This method returns Company Record.
   public SObject returnCompanyRecords(Id companyId){
       DescribeSObjectResult dsr = CheckPermissionUtility.getDescribeSObjectResult('WMLL__Company__c');
       List<string> lstComanyField = new List<string>{'WMLL__BranchWz2008__c','WMLL__Branch__c','WMLL__Lead_Status__c','WMLL__Rating__c','WMLL__City__c','WMLL__CountryCode2__c','WMLL__CountryName__c',
                                    'WMLL__Domain__c','WMLL__Email__c','WMLL__Fax__c','WMLL__HouseNumber__c','WMLL__Id__c','WMLL__Phone__c','WMLL__AnnualRevenue__c','WMLL__Region__c','WMLL__Size__c','WMLL__Street__c','WMLL__Zip__c'
       };
       
       if(companyId!=null && CheckPermissionUtility.checkSomePermissionsObject(dsr) && DMLManager.sobjFieldPermission('WMLL__Company__c',lstComanyField)){
            CompanyRecordWhenMerged = [Select Id, Name,ownerId, BranchWz2008__c, Branch__c,Lead_Status__c,Rating__c,
                                            City__c, CountryCode2__c, CountryName__c, Domain__c, Email__c, Fax__c,
                                            HouseNumber__c, Id__c, Phone__c,AnnualRevenue__c, Region__c, Size__c, Street__c,
                                            Zip__c From Company__c Where Id = : companyId];
        }
        // boolean bl = flsService.checkWithMessage(CompanyRecordWhenMerged);
        return (SObject) CompanyRecordWhenMerged;
   }
   
//   This method returns Account/Lead Record.
   public SObject returnDupSObjectRecord(Id sObectId){
       List<string> lstAccFields = new List<string>{
            'Wmll__Id__c',
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
        List<string> lstLeadFields = new List<string>{
            'Status',
            'Rating',
            'LastName',
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
       String objType = sObectId.getSObjectType().getDescribe().getName();
       if(objType.equals('Account') && CheckPermissionUtility.checkSomePermissionsObject(Account.SObjectType.getDescribe()) && DMLManager.sobjFieldPermission('Account',lstAccFields)){
           
           Account acc = [select OwnerId,Id__c,Name,Rating,LeadLab4SF_Annual_Revenue__c,LeadLab4SF_No_of_Employees__c,LeadLab4SF_Industry__c
                            ,BillingCity,ShippingCity,BillingCountry,ShippingCountry,Website,Fax,BillingStreet,ShippingStreet
                            ,Phone,BillingState,ShippingState,BillingPostalCode,ShippingPostalCode from Account where id =:sObectId];
            sObjRecordWhenMerged =  (sObject) acc;
       }else if(objType.equals('Lead') && CheckPermissionUtility.checkSomePermissionsObject(Lead.SObjectType.getDescribe()) && DMLManager.sobjFieldPermission('Lead',lstLeadFields)){
           Lead ld = [select Status,Rating,Name,LastName,LeadSource,OwnerId,ID__c,Company,LeadLab4SF_Industry__c,WMLL__LeadLab4SF_No_of_Employees__c ,LeadLab4SF_Annual_Revenue__c
                        ,Website,Email,Street,Phone,City,State,Country,PostalCode from Lead where Id =:sObectId];
            sObjRecordWhenMerged =  (sObject) ld;
       }
       if(sObjRecordWhenMerged!=null){
        //   flsService.checkWithMessage(sObjRecordWhenMerged);
       }
       return sObjRecordWhenMerged;
   }
   
  //This method merges (Saves in DB) the record After Selecting Master Record From VF Page & Fields To Be Merged.  
  public PageReference mergeDuplicate(){  
       if(selectedMode != null && selectedMode.equals('Lead')){
           //merge company to Lead
            return mergeCompany(companyLeadMap,mergeWizard,new Lead(id=selectedSobjectId));
       }else if(selectedMode != null && selectedMode.equals('Account')){
           //merge company to Account
            return mergeCompany(companyAccountMap,mergeWizard,new Account(id=selectedSobjectId));
       }
       return null;
  }
  
  
  public PageReference mergeCompany(Map<String,String> sObjectFieldMap,List<ShowMergeFieldWizard> wrapper,Sobject sobj){
      SObject mergeSelectedSobject = sobj;
      mergeSelectedSobject.put('WMLL__Unmerge_Available__c',true);
      List<Sobject> lstOfSobjectToBeMigrated;
      Integer i = -1;
      PageReference pageref;
        if(mergeWizard!=null && mergeWizard.size()>0){
            for(String ldFieldApi : sObjectFieldMap.keySet()){
              i++;
              if(mergeWizard[i].sobjRec.accFieldApiName.equals(ldFieldApi) && mergeWizard[i].selected.equals('Lead')){
                  mergeSelectedSobject.put(ldFieldApi,mergeWizard[i].sobjRec.accfieldValue);
              }else if(mergeWizard[i].compRec.comFieldApiName.equals(sObjectFieldMap.get(ldFieldApi)) && mergeWizard[i].selected.equals('Company')){
                  mergeSelectedSobject.put(ldFieldApi,mergeWizard[i].compRec.comfieldValue);
              }
            }
            if(selectedMode.equals('Lead')){
                lstOfSobjectToBeMigrated = migrateVisists(selectedSobjectId,companyId,'WMLL__Lead__c','WMLL__Company__c');
            }else if(selectedMode.equals('Account')){
                lstOfSobjectToBeMigrated = migrateVisists(selectedSobjectId,companyId,'WMLL__Account__c','WMLL__Company__c');
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
          if(lstOfSobjectToBeMigrated.size()>0){
              //updating account/Lead .
              errormsg = updateMergedSObject(new List<SObject>{mergeSelectedSobject});
              
              DescribeSObjectResult dsr = CheckPermissionUtility.getDescribeSObjectResult('WMLL__Visit__c');
              DescribeSObjectResult dsrCom = CheckPermissionUtility.getDescribeSObjectResult('WMLL__Company__c');
              
              if(errormsg==null && lstOfSobjectToBeMigrated!=null && dsr.isUpdateable()){
            // updating visits for merged Account/Lead
                  update lstOfSobjectToBeMigrated;
                  //deleting the company after merging. 
                  if(dsrCom!=null && dsrCom.isDeletable()){
                      deleteCompany(companyId);
                  }
                  pageref = new PageReference('/'+selectedSobjectId);
              }
          }else{	
              errormsg = label.NoVisitsToMerge;
          }
        }catch(Exception ee){
        //   system.debug('ee::'+ee.getLineNumber()+' : '+ee.getMessage());
        //   Database.rollback(sp);
        }
        if(pageref != null){
           pageref.setRedirect(true);
           return pageref;
        }else{
           return null;
        }
  }
  
  // This method update the Lead/Account after merge.
  // This method returns error string If exists.
  public String updateMergedSObject(list<Sobject> objList){
        Schema.DescribeSObjectResult r = objList[0].getSObjectType().getDescribe();
        String objName = r.getName();
        Set<String> RequiredField = new Set<String>();
        Integer objListSize = -1;
        if (r.isUpdateable()){
            Database.SaveResult cr = Database.Update(objlist[0], false);
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
                                return String.valueof(label.AccountMergeValidation+ ': ' + err.getMessage());
                            }else{
                                return String.valueof(label.LeadMergeValidation+ ': ' + err.getMessage());
                            }
                        }else if(String.valueof(err.getStatusCode()).contains('REQUIRED_FIELD_MISSING')){
                            // if(RequiredField.size()==1){
                                if(objName=='Account'){
                                    return String.valueof(label.AccountMergeFieldValidation).replace('[MandatoryFields]',String.join(new List<String>(RequiredField),','));
                                }else{
                                    return String.valueof(label.LeadMergeFieldValidation).replace('[MandatoryFields]',String.join(new List<String>(RequiredField),','));
                                }
                            // }else if(RequiredField.size()>1){
                            //     if(objName=='Account'){
                            //         companieswithError.add(new CompanyUnableToMerge(String.valueof(objList.get('name')),String.valueof(label.MultipleRequiredFieldValidationEN).replace('[MandatoryFields]',String.join(new List<String>(RequiredField),','))));
                            //     }else{
                            //         companieswithError.add(new CompanyUnableToMerge(String.valueof(objList.get('name')),String.valueof(label.MultipleFieldValidationMergeEN).replace('[MandatoryFields]',String.join(new List<String>(RequiredField),','))));
                            //     }
                            // }
                        }else if(String.valueof(err.getStatusCode()).contains('DUPLICATE_VALUE')){
                            if(objName=='Account'){
                                return String.valueof(label.AccountDuplicateMergeError+err.getMessage().replace('duplicate value found',''));
                            }else{
                               return String.valueof(label.LeadDuplicateMergeError+err.getMessage().replace('duplicate value found',''));
                            }
                        }else{
                            return String.valueof(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            return null;
        }else{
            return (objName=='Account'?String.valueof(Label.NotEnoughAccessToMerge).replace('[SOBJECT]','Account'):String.valueof(Label.NotEnoughAccessToMerge).replace('[SOBJECT]','Lead'));
        }
    }
  
  //This method migrate All the visits for master record.
  public List<SObject> migrateVisists(ID mergedObjectId,ID objectToBeMerged,String mergedObjecField,String objectToBeMergedField){
      List<SObject> lstOfSobject;
      if(mergedObjectId!=null && objectToBeMerged!=null){
          String query = 'select id,'+mergedObjecField+','+objectToBeMergedField+' from WMLL__Visit__c where'+' '+ objectToBeMergedField+'=:objectToBeMerged';
          lstOfSobject = Database.query(query);
      }
      if(lstOfSobject!=null && lstOfSobject.size()>0){
          for(SObject sbj :lstOfSobject){
              sbj.put(mergedObjecField,mergedObjectId);
              sbj.put(objectToBeMergedField,null);
          }
      }
      return lstOfSobject;
  }
  
  public Pagereference cancelMerge(){
      Pagereference pageref = new Pagereference('/'+companyId);
      pageref.setRedirect(true);
      return pageref;
  }
  public void deleteCompany(Id recId){
      if(!String.isEmpty(recId) && recId.getSObjectType().getDescribe().isDeletable()){ 
            DMLManager.deleteAsSystem(new List<company__c>{new company__c(Id=recId)});
      }
  }
  
  //wrapper that holds the all content to show on duplicate merge wizard (VF Page).
  public class ShowMergeFieldWizard{
      public SObjectRecord sobjRec{get;set;}
      public CompanyRecord compRec{get;set;}
      public String selected{get;set;}
      public ShowMergeFieldWizard(CompanyRecord company,SObjectRecord obj,String selected1){
          compRec = company;
          sobjRec = obj;
          selected  = selected1;
      }
  } 
  //wrapper that holds lead/account record information.
  public class SObjectRecord{
      public String accFieldApiName{get;set;}
      public String accFieldLabel{get;set;}
      public String  accfieldValue{get;set;}
      public SObjectRecord(String fieldApiName,String fieldLabel,String fieldValue){
          accFieldApiName = fieldApiName;
          accFieldLabel = fieldLabel;
          accfieldValue = fieldValue;
      }
  }
  //wrapper that holds company record information.
  public class CompanyRecord{
      public String comFieldApiName{get;set;}
      public String comFieldLabel{get;set;}
      public String  comfieldValue{get;set;}
      public CompanyRecord(String fieldApiName,String fieldLabel,String fieldValue){
          comFieldApiName = fieldApiName;
          comFieldLabel = fieldLabel;
          comfieldValue = fieldValue;
      }
  }
}