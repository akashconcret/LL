public with sharing class CompanyListCtrl {
    public boolean isLightningExperience {get;set;}
    public string CompanyListViewInClassic {get;set;}
    public string ListViewId{get;set;}
    List<ListView> lstOfView;
    public CompanyListCtrl(){
        isLightningExperience = false;
        string id = UserInfo.getUserId();
        
        
        for (User u: [SELECT Id, UserPreferencesLightningExperiencePreferred FROM User WHERE Id =: id LIMIT 1]){
            isLightningExperience = u.UserPreferencesLightningExperiencePreferred;
        }
        DescribeSObjectResult dsr = CheckPermissionUtility.getDescribeSObjectResult('ListView');
        
        if(isLightningExperience && CheckPermissionUtility.checkSomePermissionsObject(dsr)){
            lstOfView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'WMLL__Company__c' AND Name = 'All' limit 1];
        }
        if(lstOfView!=null && lstOfView.size()==1){
            ListViewId = lstOfView[0].Id;
        }else if(lstOfView!=null && lstOfView.size()==0 && CheckPermissionUtility.checkSomePermissionsObject(dsr)){
            lstOfView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'WMLL__Company__c' limit 100];
            ListViewId = lstOfView[0].Id;
        }
        if(!isLightningExperience){
            CompanyListViewInClassic = WMLL__company__c.getSobjectType().getDescribe().getKeyPrefix();
            // redirectToCompnayListViewInClassic();
        }
    }
    public Pagereference redirectToCompnayListViewInClassic(){
        Pagereference pageref = new Pagereference('/'+CompanyListViewInClassic);
        pageref.setRedirect(true);
        return pageref;
    }
}