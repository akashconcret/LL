public with sharing class FetchVisitsScheduler implements Schedulable {

    private final String scheduleName = FetchVisitsScheduler.class.getName();

    private final Integer minutesInHour = 60;
    private final Integer minutesTwoHours = minutesInHour * 2;
    private final Integer minutesFourHours = minutesInHour * 4;
    private final Integer minutesInDay = minutesInHour * 24;
    private final Integer minutesInHalfDay = minutesInDay / 2;


    private final Map<String, Integer> fetchIntervalToMinutes = new Map<String, Integer> {
        Constants.FETCH_INTERVAL_6AM => minutesInDay,
        Constants.FETCH_INTERVAL_12H => minutesInHalfDay,
        Constants.FETCH_INTERVAL_2H => minutesTwoHours,
        Constants.FETCH_INTERVAL_1H => minutesInHour,
        Constants.FETCH_INTERVAL_4H => minutesFourHours
    };

    public FetchVisitsScheduler() {}

    public void execute(SchedulableContext context) {

        final Setting__c settings = Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME);

        final Integer timeRange = fetchIntervalToMinutes.get(settings.Retrieval_Period__c);

        final String fromTime = String.valueOf(Datetime.now().addMinutes(-timeRange).getTime() / 1000);
        final String toTime = String.valueOf(Datetime.now().getTime() / 1000);

        fetchVisits(fromTime, toTime);
    }

    public void scheduleDaily() {
        schedule('0 10 6 * * ?');
    }

    public void scheduleTwiceDaily() {
        schedule('0 10 */12 * * ?');
    }

    public void scheduleHourly() {
        schedule('0 10 * * * ?');
    }

    public void scheduleEveryTwoHours() {
        schedule('0 10 */2 * * ?');
    }

    public void scheduleEveryFourHours() {
        schedule('0 10 */4 * * ?');
    }

    public void abort() {
        final List<CronTrigger> jobs = [Select Id, CronJobDetail.Name From CronTrigger
                                        Where CronJobDetail.Name = :schedulename];

        if(!jobs.isEmpty())
            System.abortJob(jobs.get(0).Id);
    }

    private void schedule(String cronPattern) {

        abort();

        System.schedule(scheduleName, cronPattern, new FetchVisitsScheduler());
    }

    public void fetchVisits(String fromDate, String toDate) {
        final Fetcher.IRange range = new Fetcher.DateRange(fromDate, toDate);
        new Fetcher(range,false);
    }
}