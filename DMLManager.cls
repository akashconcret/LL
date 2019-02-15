/**
* Copyright (c), 2014, Patron Holdings LLC
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
* - Neither the name of the Patron Holdings nor the names of its contributors
*      may be used to endorse or promote products derived from this software without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class DMLManager {
    // Items in the following set must be entered in lower case
    private static Set<String> exceptionValues = new Set<String> {'id','isdeleted','createddate','systemmodstamp','lastmodifiedbyid','createdbyid','lastmodifieddate'};
    // static SettingsController settingsCtrl = new SettingsController();
    private static Map<Operation,Map<SObjectType,List<String>>> cachedRestrictedFields = new Map<Operation,Map<SObjectType,List<String>>>();
    
    public enum Operation {OP_INSERT,OP_UPDATE,OP_DELETE,OP_UPSERT}
    public static Result companieswithError{get;set;}
    public static List<CompanyUnableToConvert> listCompanieswithError{get;set;}
    
    // CRUD/FLS-safe DML operations. These honor the CRUD and FLS permissions of the running user
    public static void insertAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_INSERT);}
    public static void updateAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_UPDATE);}
    public static void upsertAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_UPSERT);}
    public static void deleteAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_DELETE);}
    public static void insertAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_INSERT);}
    public static void updateAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_UPDATE);}
    public static void upsertAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_UPSERT);}
    public static void deleteAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_DELETE);}
    public static void upsertByFieldAsUser(List<SObject> objList, String fieldName){
        final List<SObject> inserts = new List<SObject>();
        final List<SObject> updates = new List<SObject>();
        splitUpsertOnField(objList, fieldName, inserts, updates);
        insertAsUser(inserts);
        updateAsUser(updates);
    } 
    
    // Pass-thru methods to raw DML operations. 
    // Use these sparingly, and only with good reason, since the DML operations are not CRUD/FLS safe
    public static void insertAsSystem(sObject obj){ insertAsSystem(new List<SObject>{ obj }); }
    public static void updateAsSystem(sObject obj){ updateAsSystem(new List<SObject>{ obj }); }
    public static void upsertAsSystem(sObject obj){ upsertAsSystem(new List<SObject>{ obj }); }
    public static void upsertGroupMemberAsSystem(List<SObject> members){ upsert members; }
    public static void deleteAsSystem(sObject obj){ deleteAsSystem(new List<SObject>{ obj }); }
    //public static void deleteAsCompanies(Company__c obj){ deleteAsCompanies(new List<Company__c>{ obj }); }
    public static void insertAsSystem(List<SObject> objList){ 
        if(objList!=null  && objList.size()>0 && objList[0].getSObjectType().getDescribe().isCreateable()){
            insert objList;
        }
        
    }
    public static void updateAsSystem(List<SObject> objList){ 
        if(objList!=null  && objList.size()>0 && objList[0].getSObjectType().getDescribe().isUpdateable()){
            update objList;
        }
    }
    public static void upsertAsSystem(List<SObject> objList){ upsertByFieldAsSystem(objList, 'Id__c'); }
    public static void deleteAsSystem(List<SObject> objList){
        if(objList!=null  && objList.size()>0 && objList[0].getSObjectType().getDescribe().isDeletable()){
            delete objList;
        }
    }
    
    //This method is called from Controller "CompanyCtrl" to convert companies to accounts. 
    //This method allows the conversion of those Accounts only which produce No error during conversion.
    //Because of the Validations && Required fields && any other error.
    public static Result upsertMassAsSystem(List<Account> objList,Integer compHavingNoVisits){
        companieswithError = new Result();
        listCompanieswithError = new List<CompanyUnableToConvert>();
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        Set<String> accountRequiredField = new Set<String>();
        Set<String> accountGeneratedSuccessFully = new Set<String>();
        Integer i=0;
        Integer objListSize = -1;
        if (r.isUpdateable() && r.isCreateable()){
            Schema.SObjectField f = Account.Fields.Id__c;
            Database.UpsertResult [] cr = Database.upsert(objlist,f,false);
            for (Database.UpsertResult sr : cr) {
                objListSize++;
                if(sr.isSuccess()){
                    i++;
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        if(err.getFields().size()>0){
                            for(String str : err.getFields()){
                                accountRequiredField.add(str);
                            }
                        }
                        if(String.valueof(err.getStatusCode()).contains('CUSTOM_VALIDATION_EXCEPTION') && label.LeadwebvalidationEN!=null){
                            listCompanieswithError.add(new CompanyUnableToConvert(String.valueof(objList.get(objListSize).Id),String.valueof(objList.get(objListSize).name),String.valueof(label.LeadwebvalidationEN+ ': ' + err.getMessage())));
                        }else if(String.valueof(err.getStatusCode()).contains('REQUIRED_FIELD_MISSING')){
                            if(accountRequiredField.size()==1){
                                listCompanieswithError.add(new CompanyUnableToConvert(String.valueof(objList.get(objListSize).Id),String.valueof(objList.get(objListSize).name),String.valueof(label.FieldValidationEN).replace('[MandatoryFields]',String.join(new List<String>(accountRequiredField),','))));
                            }else if(accountRequiredField.size()>1){
                                listCompanieswithError.add(new CompanyUnableToConvert(String.valueof(objList.get(objListSize).Id),String.valueof(objList.get(objListSize).name),String.valueof(label.MultipleRequiredFieldValidationEN).replace('[MandatoryFields]',String.join(new List<String>(accountRequiredField),','))));
                            }
                        }else if(String.valueof(err.getStatusCode()).contains('DUPLICATE_VALUE')){
                            listCompanieswithError.add(new CompanyUnableToConvert(String.valueof(objList.get(objListSize).Id),String.valueof(objList.get(objListSize).name),String.valueof(label.DUPLICATE_VALUE+err.getMessage().replace('duplicate value found',''))));
                        }else{
                            listCompanieswithError.add(new CompanyUnableToConvert(String.valueof(objList.get(objListSize).Id),String.valueof(objList.get(objListSize).name),String.valueof(err.getStatusCode() + ': ' + err.getMessage())));
                        }
                       accountRequiredField.clear(); 
                    }
                }
            }
            if(i>0 && cr.size()>0){
                companieswithError.successfullyConvertedCompanyCount = String.valueof(label.Mass_Record_Creation).replace('Leads','Accounts').replace('XAll',String.valueof(i)).replace('YAll',String.valueof((cr.size()+compHavingNoVisits)));
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,String.valueof(label.Mass_Record_Creation).replace('Leads','Accounts').replace('XAll',String.valueof(i)).replace('YAll',String.valueof((cr.size()+compHavingNoVisits)))));
            }
            companieswithError.lstCompanyUnableToConvert = listCompanieswithError;
            return companieswithError;
        }else{
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,String.valueof(Label.NotEnoughAccess)));
            return companieswithError;
        }
    }
    //This method is called from Controller "MassLeadCtrl" to convert companies to Leads.
    //This method allows the conversion of those Leads only which produce No error during conversion.
    //Because of the Validations && Required fields && any other error.
    public static Result upsertMassAsSystem(List<lead> objList,Integer compHavingNoVisits){
        companieswithError = new Result();
        listCompanieswithError = new List<CompanyUnableToConvert>();
        Schema.DescribeSObjectResult r = lead.sObjectType.getDescribe();
        Set<String> leadRequiredFields = new Set<String>();
        List<id> listForFailedUpsertedAcc = new List<id>();
        Integer i=0;
        Integer objListSize = -1;
        if (r.isUpdateable() && r.isCreateable()){
            Schema.SObjectField f = lead.Fields.Id__c;
            Database.UpsertResult [] cr = Database.upsert(objlist,f,false);
            for (Database.UpsertResult sr : cr) {
                objListSize++;
                if(sr.isSuccess()){
                    i++;
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        if(err.getFields().size()>0){
                           for(String str: err.getFields()){
                                leadRequiredFields.add(str);
                           }
                        }
                        if(String.valueof(err.getStatusCode()).contains('CUSTOM_VALIDATION_EXCEPTION') && label.LeadwebvalidationEN!=null){
                            listCompanieswithError.add(new CompanyUnableToConvert(objList.get(objListSize).Id,String.valueof(objList.get(objListSize).company),String.valueof(String.valueof(label.LeadwebvalidationEN).replace('Account','Lead') + ': ' + err.getMessage())));
                        }else if(String.valueof(err.getStatusCode()).contains('REQUIRED_FIELD_MISSING')){
                            if(leadRequiredFields.size()==1){
                                listCompanieswithError.add(new CompanyUnableToConvert(objList.get(objListSize).Id,String.valueof(objList.get(objListSize).company),String.valueof(label.FieldValidationEN).replace('Account','Lead').replace('[MandatoryFields]',String.join(new List<String>(leadRequiredFields),','))));
                            }else if(leadRequiredFields.size()>1){
                                listCompanieswithError.add(new CompanyUnableToConvert(objList.get(objListSize).Id,String.valueof(objList.get(objListSize).company),String.valueof(label.MultipleRequiredFieldValidationEN).replace('Account','Lead').replace('[MandatoryFields]',String.join(new List<String>(leadRequiredFields),','))));
                            }
                        }else if(String.valueof(err.getStatusCode()).contains('DUPLICATE_VALUE')){
                            listCompanieswithError.add(new CompanyUnableToConvert(objList.get(objListSize).Id,String.valueof(objList.get(objListSize).company),String.valueof(label.DUPLICATE_VALUE.replace('Account','Lead')+err.getMessage().replace('duplicate value found',''))));
                        }else{
                           listCompanieswithError.add(new CompanyUnableToConvert(objList.get(objListSize).Id,String.valueof(objList.get(objListSize).company),String.valueof(err.getStatusCode() + ': ' + err.getMessage()))); 
                        }
                        leadRequiredFields.clear();
                    }
                }
            }
            if(i>0 && cr.size()>0){
                companieswithError.successfullyConvertedCompanyCount = String.valueof(label.Mass_Record_Creation).replace('XAll',String.valueof(i)).replace('YAll',String.valueof((cr.size()+compHavingNoVisits)));
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,String.valueof(label.Mass_Record_Creation).replace('XAll',String.valueof(i)).replace('YAll',String.valueof((cr.size()+compHavingNoVisits)))));
            }
            companieswithError.lstCompanyUnableToConvert = listCompanieswithError;
           return companieswithError;
        }else{
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,String.valueof(Label.NotEnoughAccess).replace('Account','Lead')));
            return companieswithError;
        }
    }
    //sends mail after manual fetch and deletion of visits.
    public static void sendEmail(String subject,String plainText,String emailId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{emailId});
        mail.setSubject(subject);
        mail.setPlainTextBody(plainText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    //return user current theme .(Lightning / Classic)
    public static Boolean getUserTheme(){
        Boolean isLightningExperience = false;
        string id = UserInfo.getUserId();
        for (User u: [SELECT Id, UserPreferencesLightningExperiencePreferred FROM User WHERE Id =: id LIMIT 1]){
            isLightningExperience = u.UserPreferencesLightningExperiencePreferred;
        }
        return isLightningExperience;
    }
    //return listView URL IN lightning/Classic interfaces as per user theme.
    public static Pagereference redirectAsPerUserTheme(){
        List<ListView> lstOfView;
        Pagereference pageref;
        String ListViewId;
        DescribeSObjectResult dsr = CheckPermissionUtility.getDescribeSObjectResult('ListView');
        if(getUserTheme() && CheckPermissionUtility.checkSomePermissionsObject(dsr)){
          lstOfView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'WMLL__Company__c' AND Name = 'All'];
            if(lstOfView!=null && lstOfView.size()==1){
                ListViewId = lstOfView[0].Id;
            }else if(lstOfView!=null && lstOfView.size()==0){
                lstOfView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'WMLL__Company__c'];
                ListViewId = lstOfView[0].Id;
            }
            pageref = new Pagereference('/one/one.app#/sObject/WMLL__Company__c/list?filterName='+ListViewId);
        }else{
           pageref = new Pagereference('/' + WMLL__Company__c.SObjectType.getDescribe().getKeyPrefix());
        }
        pageref.setRedirect(true);
        return pageref;
    }
    //create error log record If error accurs in any Batch execution.
    public static void createErrorLog(AsyncApexJob asyncJob){
            LeadLab_Error_Log__c errorLog = new LeadLab_Error_Log__c();
            errorLog.Apex_Class__c = asyncJob.ApexClass.Name;
            errorLog.NumberOfErrors__c = asyncJob.NumberOfErrors;
            errorLog.JobItemsProcessed__c = asyncJob.JobItemsProcessed;
            //errorLog.Total_Job_Items__c = a.TotalJobItems;
            errorLog.JobType__c = asyncJob.JobType;
            errorlog.Status__c = asyncJob.Status;
            errorLog.ExtendedStatus__c = asyncJob.ExtendedStatus;
            if(errorLog!=null && errorLog.getSObjectType().getDescribe().isAccessible() && errorLog.getSObjectType().getDescribe().isCreateable()){
                insert errorLog;
            }
    }
    //returns default value for particular object's picklist type field.
    public static String returnDefaultPicklistValue(sObject sobj,String fieldName){
        String defaultVal;
        
        Schema.DescribeSObjectResult F = sobj.getSObjectType().getDescribe();
        List <Schema.PicklistEntry> pickVals = F.fields.getMap().get(fieldName).getDescribe().getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals) {
            if (pv.isDefaultValue()) {
                defaultVal = pv.getValue();
            }    
        }
        return defaultVal;
    }
    
    // This method returns true if there is no required field without default value for the given Object.
    // otherwise returns false.
    // Default values are set from set up page.
    public static boolean isScheduledVisitFetchAllowed(sObject objectName){
        boolean fetchVisits = true;
        SettingsController settingsCtrl = new SettingsController();
        Schema.sObjectType sobjectType = objectName.getSObjectType();
        Schema.DescribeSObjectResult schemaResult = sobjectType.getDescribe();
        for(SettingsController.ObjectForParsing allData:settingsCtrl.allData){
            if(allData.objectLabel == schemaResult.getLabel()){
                for(SettingsController.MandatoryFieldWrapper MandatoryField : allData.mandatoryFields){
                    if(String.isEmpty(String.valueof(MandatoryField.defaultValue))){
                        fetchVisits = false;
                        break;
                    }
                }
            }
        }
        return fetchVisits;
    }
    //Gives permission access of List of fields for particular object.
    public static boolean sobjFieldPermission(string sobj,List<String> lstOfFields){
        Boolean validateAllFields = true;
        DescribeSObjectResult ckeckCompanyPermission = CheckPermissionUtility.getDescribeSObjectResult(sobj);
        for(string str : lstOfFields){
            DescribeFieldResult check = CheckPermissionUtility.getDescribeFieldResult(ckeckCompanyPermission,str);
            if(!CheckPermissionUtility.checkAllPermissionsField(check)){
                validateAllFields = false;
                return false;
            }
        }
        return validateAllFields;
    }
    public static void upsertByFieldAsSystem(List<SObject> objList, String fieldName){
        final List<SObject> inserts = new List<SObject>();
        final List<SObject> updates = new List<SObject>();
        splitUpsertOnField(objList, fieldName, inserts, updates);
        insertAsSystem(inserts);
        updateAsSystem(updates);
    }

    // Custom Exception Classes
    public virtual class DMLManagerException extends Exception{
        public SObjectType objType {get; private set;}
        public Operation op{get; private set;}
    }

    public class CRUDException extends DMLManagerException{
        public CRUDException(SObjectType objType, Operation op){
            this('Access Denied: ' + op + ' on ' + objType);
            this.objType = objType;
            this.op = op;
        }
    }
 
    public class FLSException extends DMLManagerException{
        public SObjectField field{get; private set;}    
        public FLSException(SObjectType objType, SObjectField field, Operation op){
            this('Access Denied: ' + op + ' on ' + objType + '.' + field);
            this.objType = objType;
            this.op = op;
            this.field = field;
        }
    }

    private static void splitUpsertOnField(List<SObject> sObjects, String fieldName,
            List<SObject> inserts, List<SObject> updates) {
        if(sObjects.isEmpty()) return;

        final String sObjectName = sobjects.get(0).getSObjectType().getDescribe().getName();

        final Set<String> existingExternalIds = new Set<String>(); 
        for(SObject sObj : sObjects){ 
            final String fieldValue = String.valueOf(sObj.get(fieldName)); 
            if(String.isEmpty(fieldValue)) continue;

            existingExternalIds.add(fieldValue); 
        } 
        
        final String query = buildUpsertSplitQuery(fieldName, sObjectName);
        final List<SObject> existingObjects = Database.query(query);

        final Map<String, String> sObjByExtId = new Map<String, String>(); 
        for(SObject sObj : existingObjects){ 
            sObjByExtId.put(String.valueOf(sObj.get(fieldName)), sObj.Id); 
        } 

        for(SObject sObj : sObjects){ 
            if(sObjByExtId.containsKey(String.valueOf(sObj.get(fieldName)))){ 
                sObj.Id = sObjByExtId.get(String.valueOf(sObj.get(fieldName))); 
                updates.add(sObj); 
            }else{ 
                inserts.add(sObj); 
            } 
        }
    }

    private static String buildUpsertSplitQuery(String fieldName, String objectName) {
        if('id'.equalsIgnoreCase(fieldName))
            return 'Select Id From ' + objectName + ' Where Id IN :existingExternalIds';
        else
            return 'Select ID, ' + fieldName + ' From ' + objectName + ' Where ' 
                + fieldName + ' IN :existingExternalIds'; 
    }

    private static void performDMLOperation(List<SObject> objList, Operation dmlOperation){
        Map<SObjectType,List<Id>> objTypeMap = analyzeDMLCollection(objList, dmlOperation);
        List<sObject> toInsert= new List<sObject>();
        List<sObject> toUpdate = new List<sObject>();

        checkCRUDPermission(objTypeMap.keySet(),dmlOperation);

        if(dmlOperation == Operation.OP_INSERT){
            for(SObject obj : objList){
                checkCreateAction(obj);
            }
        } else if (dmlOperation == Operation.OP_UPDATE || dmlOperation == Operation.OP_UPSERT){
            
            Map<Id,SObject> existingRecords = getExistingRecords(objTypeMap);

            for(SObject obj : objList){
                SObject existingRecord = existingRecords.get(obj.Id);
                if(obj.id != null){
                    checkUpdateAction(obj,existingRecord);
                    toUpdate.add(obj);
                } else {
                    checkCreateAction(obj);
                    toInsert.add(obj);
                }
            }
        }
        // If no errors have been thrown to this point, execute the dml operation.
        if(dmlOperation == Operation.OP_INSERT){insert objList;} 
            else if (dmlOperation == Operation.OP_UPDATE){update objList;} 
                else if (dmlOperation == Operation.OP_UPSERT){insert toInsert; update toUpdate;}
                    else if (dmlOperation == Operation.OP_DELETE){
                            if(objList.size()>0 && objList[0].getSObjectType().getDescribe().isDeletable()) 
                                delete objList;
                    }
    }
    
    private static void upsertCollection(List<SObject> objList){
        // This is to deal with a call to upsertAsUser with a singular object.
        // Since we wrap that into a List<SObject> (which can't be passed into an upsert)
        // we unpack it and upsert the object individually.
        if(objList.size() == 1){
            DMLManager.upsertAsUser(objList.get(0));
        } else {
            DMLManager.upsertAsUser(objList);
        }
    } 
    
    private static Map<String,Object> getFieldMapFromExistingSObject(SObject obj){
        // Get actual fields present in object.  This serialization technique removes implicit nulls.
        String s = JSON.serialize(obj);
        Map<String,Object> fieldsMap = (Map<String,Object>) JSON.deserializeUntyped(s);
        fieldsMap.remove('attributes');
        return fieldsMap;       
    }
    
    private static void checkCreateAction(SObject obj){
        List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_INSERT).get(obj.getSObjectType());
        //Save ourselves a trip through the loop below if there are no restricted fields
        if(restrictedFields == null || restrictedFields.isEmpty()){
            return;
        }

        Map<String,Object> fieldsMap = getFieldMapFromExistingSObject(obj);
        
        // If any restricted fields are present, throw an exception
        for(String fieldName : restrictedFields){
            if(fieldsMap.get(fieldName) != null){ // if any of the restricted fields are present in the candidate, throw an exception
                throw new FLSException(obj.getSObjectType(),obj.getSObjectType().getDescribe().fields.getMap().get(fieldName),Operation.OP_INSERT);
            }
        }  
    }

    private static void checkUpdateAction(SObject obj, SObject existingRecord){
        List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE).get(obj.getSObjectType());
        //Save ourselves a trip through the loop below if there are no restricted fields
        if(restrictedFields == null || restrictedFields.isEmpty()){
            return;
        }
        
        if(existingRecord == null){
            throw new DMLManagerException('DMLManager ERROR:  An existing record could not be found for object with Id = ' + obj.Id);
        }

        Map<String,Object> fieldsMap = getFieldMapFromExistingSObject(obj);
        
        // If any of the restricted values are present and have changed in the dml candidate object, throw an exception
        for(String fieldName : restrictedFields){
            if(fieldsMap.get(fieldName) != null && fieldsMap.get(fieldName) != existingRecord.get(fieldName) ){
                throw new FLSException(obj.getSObjectType(),obj.getSObjectType().getDescribe().fields.getMap().get(fieldName),Operation.OP_UPDATE);
            }
        }    
    }


    // For update and upsert operations, retrieve a Map of all existing records, for each object that has an ID.
    // objects without an Id are skipped, because there is no existing record in the database.
    private static Map<Id,SObject> getExistingRecords(Map<SObjectType,List<Id>> objTypeMap){
        Map<ID, SObject> result = new Map<Id,SObject>();

        Map<SObjectType,List<String>> operationRestrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE);
        
        for(SObjectType objType : objTypeMap.keySet()){
            List<String> restrictedFields = operationRestrictedFields.get(objType);
            
            if(restrictedFields == null || restrictedFields.isEmpty()){
                continue;
            }

            List<Id> seenIds = objTypeMap.get(objType);
            if(seenIds.isEmpty()){
                continue;
            }

            String fieldList = String.join(restrictedFields,',');
            result.putAll((Database.query('SELECT ' + fieldList + ' FROM ' + objType.getDescribe().getName() + ' WHERE Id IN :seenIds')));
        }
        
        return result;
    }
        
    // Check CRUD permissions for the current user on the object
    private static void checkCRUDPermission(Set<SObjectType> objTypeList, Operation dmlOperation){
        for(SObjectType objType : objTypeList){
            DescribeSObjectResult describeObject = objType.getDescribe();
            if((dmlOperation == Operation.OP_INSERT && !describeObject.isCreateable()) ||
                (dmlOperation == Operation.OP_UPDATE && !describeObject.isUpdateable()) ||
                (dmlOperation == Operation.OP_DELETE && !describeObject.isDeletable()) ||
                (dmlOperation == Operation.OP_UPSERT && !(describeObject.isCreateable() && describeObject.isUpdateable()))) {
                throw new CRUDException(objType,dmlOperation);
            }
        }
    }
    
    // Get a Map of all the object types in the dml request and the list of fields for each 
    // that the current user cannot update, based on FLS security settings
    private static Map<SObjectType,List<Id>> analyzeDMLCollection(List<SObject> objList, Operation dmlOperation){
        Map<SObjectType,List<Id>> result = new Map<SObjectType,List<Id>>();
        
        for(SObject obj : objList){
            ensureRestrictedFieldsEntry(obj, dmlOperation);
        
            List<Id> seenIds = result.get(obj.getSObjectType());
            if(seenIds == null){
                seenIds = new List<Id>();
                result.put(obj.getSObjectType(),seenIds);
            }
            
            if(obj.Id == null){
                continue;
            }   
            
            seenIds.add(obj.Id);
            
        }
        return result;
    }
    
    private static void ensureRestrictedFieldsEntry(SObject obj, Operation dmlOperation){
        if(dmlOperation == Operation.OP_UPSERT){
            ensureRestrictedFields(obj,Operation.OP_INSERT);
            ensureRestrictedFields(obj,Operation.OP_UPDATE);
        }
        else{
            ensureRestrictedFields(obj,dmlOperation);
        }
    }
    
    private static void ensureRestrictedFields(SObject obj, Operation dmlOperation){
        Map<SObjectType,List<String>> operationRestrictedFields = cachedRestrictedFields.get(dmlOperation);
        if(operationRestrictedFields == null){
            operationRestrictedFields = new Map<SObjectType,List<String>>();
            cachedRestrictedFields.put(dmlOperation,operationRestrictedFields);
        }
        
        if(!operationRestrictedFields.containsKey(obj.getSObjectType())){

            DescribeSObjectResult describeObject = obj.getSObjectType().getDescribe();

            Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();

            List<String> restrictedFields = new List<String>();

            for(String nm : objectFields.keyset()){
                if(!exceptionValues.contains(nm.toLowerCase())){
                    DescribeFieldResult fr = objectFields.get(nm).getDescribe();
                    if((!fr.isCalculated()) && ((dmlOperation == Operation.OP_INSERT && !fr.isCreateable()) ||
                       (dmlOperation == Operation.OP_UPDATE && !fr.isUpdateable())) 
                    ){
                        restrictedFields.add(fr.getName());
                    }  // there is not an isDeletable method at the field level
                }
            }
            operationRestrictedFields.put(obj.getSObjectType(),restrictedFields);
        }
    }  
    public class Result{
    	public String successfullyConvertedCompanyCount{get;set;}
    	public List<CompanyUnableToConvert> lstCompanyUnableToConvert{get;set;}
    }
    public class CompanyUnableToConvert{
        public String compId{get;set;}
        public String company{get;set;}
        public String errorMessage{get;set;}
        public CompanyUnableToConvert(String cmpId,String c,String s ){
            company = c;
            errorMessage = s;
            compId = cmpId;
        }
    }
}