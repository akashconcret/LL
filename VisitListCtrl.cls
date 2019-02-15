public with sharing class VisitListCtrl {
    
    public Boolean isLightningExperience {get;set;}
    public String visitListViewInClassic {get;set;}
    public String ListViewId{get;set;}
    List<ListView> lstOfView;
    public VisitListCtrl(){
        isLightningExperience = false;
        String id = UserInfo.getUserId();
        for (User u: [SELECT Id, UserPreferencesLightningExperiencePreferred FROM User WHERE Id =: id LIMIT 1]){
            isLightningExperience = u.UserPreferencesLightningExperiencePreferred;
        }
        
        DescribeSObjectResult dsr = CheckPermissionUtility.getDescribeSObjectResult('ListView');
        if(isLightningExperience && CheckPermissionUtility.checkSomePermissionsObject(dsr)){
            lstOfView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'WMLL__Visit__c' AND Name = 'All' limit 1];
        }
        if(lstOfView!=null && lstOfView.size()==1){
            ListViewId = lstOfView[0].Id;
        }else if(lstOfView!=null && lstOfView.size()==0 && CheckPermissionUtility.checkSomePermissionsObject(dsr)){
            lstOfView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'WMLL__Visit__c'];
            ListViewId = lstOfView[0].Id;
        }
        if(!isLightningExperience){
            visitListViewInClassic = WMLL__visit__c.getSobjectType().getDescribe().getKeyPrefix();
        }
    }
//   public VisitListCtrl (){
         
//   }
//   Public pagereference ListViewURL(){
//       pagereference pagref = new pagereference('/'+WMLL__visit__c.getSobjectType().getDescribe().getKeyPrefix());
//       pagref.setRedirect(true);
//       return pagref;
//     return null;
//   }
   
   //...Kendo apex code.............
//   static final String SOQL_ACTIVITY_TEMPlATE =   'Select Id, Name, WMLL__Datetime__c, WMLL__AssignedUser__c, WMLL__Contact__c, WMLL__Duration__c, '+
//                                                   ' WMLL__Account__c, WMLL__Account__r.Name, WMLL__Id__c, WMLL__Company__c, WMLL__Company__r.Name '+ 
//                                                   'From WMLL__Visit__c Limit 50000';  

//     static final String SOQL_RECORD_TEMPLATE =   'Select Id, Name From WMLL__Visit__c';
//     static final Pattern PatternActivityHistoryGarbageType = Pattern.compile('[\\d]+[_]');
    
    // public class Visit {
    //     public String id {get;set;}
    //     public String name {get;set;}
    //     public String datetimeVal{get;set;}
    //     public String accountId {get;set;}
    //     public String accountName {get;set;}
    //     public String companyId {get;set;}
    //     public String companyName {get;set;}
    //     public String duration {get;set;}
    //     public Visit() {}

    //     public Visit(WMLL__Visit__c visitObj) {
    //         this.id = visitObj.Id;
    //         this.name = String.isBlank(visitObj.Name) ? '' : visitObj.Name;
    //         this.datetimeVal = visitObj.WMLL__Datetime__c != null ? visitObj.WMLL__Datetime__c.format() : '';
    //         if(visitObj.WMLL__Account__c != null){
    //             this.accountName = visitObj.WMLL__Account__r.Name;
    //             this.accountId = visitObj.WMLL__Account__c;
    //         }
    //         if(visitObj.WMLL__Company__c != null){
    //             this.companyName = visitObj.WMLL__Company__r.Name;
    //             this.companyId = visitObj.WMLL__LeadLab_Visit_Country__c;
    //         }
    //         this.duration = visitObj.WMLL__Duration__c == null ? '' : String.valueOf(visitObj.WMLL__Duration__c);
    //     }
    // }
    
    // public String recordName {get;set;}
    
    
    // public VisitListCtrl() {
    //     // SObject[] recs = executeSoqlTemplateForRecId(SOQL_RECORD_TEMPLATE, ApexPages.currentPage().getParameters().get('id'));
    //     // if (recs != null && !recs.isEmpty()) {
    //     //     recordName = (String)recs[0].get('Name');
    //     // }
    // }                                 
    
    // // public String getPreferencesCookieName () {
    // //     return ApexPages.currentPage().getParameters().get('id').subString(0,3);
    // // }
                                            
    // @remoteaction
    // public static boolean deleteVisitById(Id visitId) {
    //     Database.DeleteResult delResult = Database.delete(visitId);
    //     return delResult.isSuccess();
    // }
    
    // @remoteaction
    // public static Visit[] getVisits() {
    //     Visit[] results = new Visit[]{};
    //     List<Sobject> visitsSobjs = executeSoqlTemplate(SOQL_ACTIVITY_TEMPlATE);
    //     if(visitsSobjs != null) {
    //         for (SObject vs : visitsSobjs) {
    //             Visit visitObj = new Visit((WMLL__Visit__c)vs);
    //             results.add(visitObj);
    //         }
    //     }
    //     return results;
    // }
    
    
    // static Sobject[] executeSoqlTemplate(String soqlTemplate) {
    //     return Database.query(soqlTemplate);
    // }
}