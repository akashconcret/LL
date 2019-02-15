public with sharing class BatchRemoveVisits implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful,
    Schedulable {

    private final static List<Type> locators = new List<Type> {
        AccountLocator.class, LeadLocator.class, CompanyLocator.class
    };

    private final static SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();

    private final static Integer processingSize = 50;

    private final IQueryLocator locator;
    public BatchRemoveVisits(IQueryLocator locator) {
        this.locator = locator;
    }
   
    private Integer getVisitLimit() {
        final Setting__c settings = Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME);
        if(settings == null || settings.DeleteOldVisitsThreshold__c == null)
            return 0;

        if(settings.DeleteOldVisitsThreshold__c > 0)
            return settings.DeleteOldVisitsThreshold__c.intValue();

        return 0;
    }

    private List<Datetime> getSortedDatetime(Set<Datetime> datetimes) {
        final List<Datetime> sortableDatetimes = new List<Datetime>(datetimes);
        //Oldest dates first
        sortableDatetimes.sort();
        return sortableDatetimes;
    }


    private void storeVisitByTime(Map<Id, Map<Datetime, Visit__c>> visitMap, Id parent,
                                  Visit__c visit) {
        if(!visitMap.containsKey(parent))
            visitMap.put(parent, new Map<Datetime, Visit__c>());

        visitMap.get(parent).put(visit.Datetime__c, visit);
    }


    public static void scheduleHourly() {
        schedule('0 0 * * * ?');
        
    }

    private static void schedule(String cronPattern) {

        final Map<String, IQueryLocator> jobs = getJobMap();
        abortJobs(jobs.keySet());

        for(String name : jobs.keySet())
            System.schedule(name, cronPattern, new BatchRemoveVisits(jobs.get(name)));
    }

    public static void abortJobs() {
        final Map<String, IQueryLocator> jobs = getJobMap();
        abortJobs(jobs.keySet());
    }

    private static void abortJobs(Set<String> names) {
        final List<CronTrigger> jobs = [Select Id, CronJobDetail.Name From CronTrigger Where CronJobDetail.Name = :names];
        flsService.checkWithException(jobs);

        for(CronTrigger job : jobs)
            System.abortJob(job.Id);
    }

    private static Map<String, IQueryLocator> getJobMap() {
        final Map<String, IQueryLocator> jobs = new Map<String, IQueryLocator>();

        for(Type locator : locators)
            jobs.put(locator.getName(), (IQueryLocator) locator.newInstance());
        
        system.debug('jobs::'+jobs.keyset());
        return jobs;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        return this.locator.getQueryLocator();
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(this, processingSize);
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        system.debug('scope::'+scope);
        final Integer visitLimit = getVisitLimit();
        system.debug('visitLimit::'+visitLimit);
        if(visitLimit <= 0) return;

        final Map<Id, SObject> scopeMap = new Map<Id, SObject>(scope);

        final List<Visit__c> visits = [Select Id, Datetime__c, Lead__c, Account__c, Company__c
                                       From Visit__c
                                       Where(Lead__c In :scopeMap.keySet() Or
                                             Account__c In :scopeMap.keySet() Or
                                             Company__c In :scopeMap.keySet())
                                       Order By CreatedDate Asc];
        flsService.checkWithException(visits);
        system.debug('visits:::'+visits);
        final Map<Id, Map<Datetime, Visit__c>> visitsByParent = new Map<Id, Map<Datetime, Visit__c>>();
        final List<Visit__c> visitsToDelete = new List<Visit__c>();

        for(Visit__c visit : visits) {
            system.debug('EnteredIN1st');
            if(String.isNotEmpty(visit.Account__c))
                storeVisitByTime(visitsByParent, visit.Account__c, visit);
            else if(String.isNotEmpty(visit.Lead__c))
                storeVisitByTime(visitsByParent, visit.Lead__c, visit);
            else if(String.isNotEmpty(visit.Company__c))
                storeVisitByTime(visitsByParent, visit.Company__c, visit);
        }
        system.debug('visitsByParent::'+visitsByParent.size());
        for(Id parentId : visitsByParent.keySet()) {
            final Map<Datetime, Visit__c> visitsByDate = visitsByParent.get(parentId);
            if(visitsByDate.size() <= visitLimit) continue;
            
            //Delete oldest visits until linked visits is size of threshold
            final List<Datetime> sortedDatetimes = getSortedDatetime(visitsByDate.keySet());
            system.debug('diff:::'+(sortedDatetimes.size() - visitLimit));
            for(Integer i = 0; i < sortedDatetimes.size() - visitLimit; i++)
                visitsToDelete.add(visitsByDate.get(sortedDatetimes.get(i)));
        }
        system.debug('visitsToDelete:::'+visitsToDelete.size());
        // try{
            DMLManager.deleteAsSystem(visitsToDelete);
        //     system.debug('true');
        // }catch(Exception ee){
        //     system.debug('ee:::'+ee.getmessage());
        // }
    }

    public void finish(Database.BatchableContext context) {
        AsyncApexJob a = [Select Id,JobType,Status,ApexClass.Name, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :context.getJobId()]; 
        if(a!=null && a.NumberOfErrors!=0){
            DMLManager.createErrorLog(a);
        }
    }

    public interface IQueryLocator {
        Database.QueryLocator getQueryLocator();
        String getName();
    }

    public class AccountLocator implements IQueryLocator {
        public Database.QueryLocator getQueryLocator() {
            final List<SObject> sObjs = [Select Id From Account Limit 50000];
            flsService.checkWithException(sObjs);

            return Database.getQueryLocator([Select Id From Account Limit 50000]);
        }
        public String getName() {
            return BatchRemoveVisits.class.getName() + 'Account';
        }
    }

    public class LeadLocator implements IQueryLocator {
        public Database.QueryLocator getQueryLocator() {
            final List<SObject> sObjs = [Select Id From Lead Limit 50000];
            flsService.checkWithException(sObjs);

            return Database.getQueryLocator([Select Id From Lead Limit 50000]);
        }
        public String getName() { 
            return BatchRemoveVisits.class.getName() + 'Lead';
        }
    }

    public class CompanyLocator implements IQueryLocator {
        public Database.QueryLocator getQueryLocator() {
            final List<SObject> sObjs = [Select Id From Company__c Limit 50000];
            flsService.checkWithException(sObjs);

            return Database.getQueryLocator([Select Id From Company__c Limit 50000]);
        }
        public String getName() {
            return BatchRemoveVisits.class.getName() + 'Company';
        }
    }
}