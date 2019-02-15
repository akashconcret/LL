public with sharing class Scheduler implements Schedulable {

    private final static String jobName = 'ScheduledJob';

    public void execute(SchedulableContext SC) {
        if(!Test.isRunningTest())
            matchVisits(null, null);
    }


    @future(callout = true)
    static public void matchVisits(Datetime fromDate, Datetime toDate) {
        //get Leads from webservice
        final Manager mgr = new Manager();
    }

    public static String scheduleNightly() {
        String scheduleName = Constants.SCHEDULER_NAME;

        //only schedule if there is not already a job with this name
        if(!Utils.cronJobExists(scheduleName)) {
            //time pattern in cronjob format (Seconds Minutes Hours Day_of_month Month Day_of_week optional_year)
            String cronjobPattern = '0 0 3 * * ?'; // runs every day at 3am

            Scheduler scheduler = new Scheduler();
            String jobID = System.schedule(jobName, cronjobPattern,
                                           scheduler);

            return jobID;
        }

        //error code
        return '-1';
    }

}