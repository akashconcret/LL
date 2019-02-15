@IsTest
public with sharing class FetchVisitsSchedulerTest {

	@isTest
	private static void visitFetchScheduleTest() {
		final String schedulename = FetchVisitsScheduler.class.getName();

		TestUtils.prepareSettings();

// 		System.assert([Select Id, CronJobDetail.Name, CronExpression 
// 			From CronTrigger Where CronJobDetail.Name = :schedulename].isEmpty());

		final FetchVisitsScheduler scheduler = new FetchVisitsScheduler();


		scheduler.scheduleDaily();
		final List<CronTrigger> dailyTriggers = [Select Id, CronJobDetail.Name, CronExpression 
			From CronTrigger Where CronJobDetail.Name = :schedulename];

		System.assertEquals(1, dailyTriggers.size());
		System.assertEquals('0 10 6 * * ?', dailyTriggers.get(0).CronExpression );



		scheduler.scheduleTwiceDaily();
		final List<CronTrigger> biDailyTriggers = [Select Id, CronJobDetail.Name, CronExpression 
			From CronTrigger Where CronJobDetail.Name = :schedulename];

		System.assertEquals(1, biDailyTriggers.size());
		System.assertEquals('0 10 */12 * * ?', biDailyTriggers.get(0).CronExpression);



		scheduler.scheduleHourly();
		final List<CronTrigger> hourlyTriggers = [Select Id, CronJobDetail.Name, CronExpression 
			From CronTrigger Where CronJobDetail.Name = :schedulename];

		System.assertEquals(1, hourlyTriggers.size());
		System.assertEquals('0 10 * * * ?', hourlyTriggers.get(0).CronExpression);



		scheduler.scheduleEveryTwoHours();
		final List<CronTrigger> biHourlyTriggers = [Select Id, CronJobDetail.Name, CronExpression 
			From CronTrigger Where CronJobDetail.Name = :schedulename];

		System.assertEquals(1, biHourlyTriggers.size());
		System.assertEquals('0 10 */2 * * ?', biHourlyTriggers.get(0).CronExpression);



		scheduler.scheduleEveryFourHours();
		final List<CronTrigger> quaterHourlyTriggers = [Select Id, CronJobDetail.Name, CronExpression 
			From CronTrigger Where CronJobDetail.Name = :schedulename];

		System.assertEquals(1, quaterHourlyTriggers.size());		
		System.assertEquals('0 10 */4 * * ?', quaterHourlyTriggers.get(0).CronExpression);
	}
}