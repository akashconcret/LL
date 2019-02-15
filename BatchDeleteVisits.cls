public with sharing class BatchDeleteVisits implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    public date startDate;
    public date endDate;
    public BatchDeleteVisits(date startDateToDel,date endDateToDel){
        startDate = startDateToDel;
        endDate  =  endDateToDel;
    }
    public Iterable<sObject> start(Database.BatchableContext context) {
        list<Visit__c> lst;
        if(startDate.daysBetween(endDate)>0){
            lst = [Select CreatedDate,Id from Visit__c where DAY_ONLY(CreatedDate)>=:startDate AND DAY_ONLY(CreatedDate)<=:endDate];
        }else if(startDate.daysBetween(endDate)==0){
            lst = [Select CreatedDate,Id from Visit__c where DAY_ONLY(CreatedDate)=:startDate];
        }
        return lst;
    }
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        if(scope.size()>0 && scope[0].getSObjectType().getDescribe().isDeletable()){
            delete scope;
        }
    }
    public void finish(Database.BatchableContext context) {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status,JobType,ExtendedStatus,ApexClass.Name, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName FROM AsyncApexJob WHERE Id = :context.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        string plainText = String.format(Label.Dear, new List<String> {a.CreatedBy.FirstName == null ? '' : a.CreatedBy.FirstName+' ', a.CreatedBy.LastName}) +
                              '\n\n' + Label.BatchDeleteVisits_SuccessMessage;
        DMLManager.sendEmail(Label.BatchDeleteVisits_Subject,plainText,a.CreatedBy.Email);
        if(a!=null && a.NumberOfErrors!=0){
            //Creating Error Log If there is any error in this batch execution.
            DMLManager.createErrorLog(a);
        }
    }
}