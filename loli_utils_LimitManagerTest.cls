@isTest
public with sharing class loli_utils_LimitManagerTest {

    private static final Integer scheduledJobsCount = 99;
    private static final Integer batchHoldingSlotsCount = 99;
    private static final Integer batchQueuedSlotsCount = 1;
    private static final Integer batchSlotsTotalCount = batchHoldingSlotsCount + batchQueuedSlotsCount;
    private static loli_utils_IPlatformLimit bLimitService;


    //----------------------------- getAvailableBatchSlots ----------------------------------//

    //---- Happy path ----//

    private static TestMethod void getAvailableBatchSlots_NoJobQueued() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);

        Integer calculatedNumberOfSlots = bLimitService.getAvailableBatchSlots();


        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(batchSlotsTotalCount, calculatedNumberOfSlots);
    }

    private static TestMethod void getAvailableBatchSlots_JobQueued() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);
        Integer numberOfJobsQueued = 10;

        Test.enqueueBatchJobs(numberOfJobsQueued);
        Integer calculatedNumberOfSlots = bLimitService.getAvailableBatchSlots();

        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(batchSlotsTotalCount - numberOfJobsQueued, calculatedNumberOfSlots);
    }

    private static TestMethod void getAvailableBatchSlots_JobQueueListFilled() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);

        Test.enqueueBatchJobs(batchQueuedSlotsCount);
        Integer calculatedNumberOfSlots = bLimitService.getAvailableBatchSlots();


        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(batchSlotsTotalCount - batchQueuedSlotsCount, calculatedNumberOfSlots);
    }

    private static TestMethod void getAvailableBatchSlots_JobCompleted() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);
        Integer numberOfJobsQueued = 10;
        Test.startTest();
        Test.enqueueBatchJobs(numberOfJobsQueued);
        Test.stopTest();

        Integer calculatedNumberOfSlots = bLimitService.getAvailableBatchSlots();

        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(batchSlotsTotalCount, calculatedNumberOfSlots);
    }

    //----------------------------- isBatchSlotAvailable ----------------------------------//

    //---- Happy path ----//

    private static TestMethod void isBatchSlotAvailable_NoJobQueued() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);

        Boolean isBatchSlotAvailable = bLimitService.isBatchSlotAvailable(batchSlotsTotalCount);

        System.assert(isBatchSlotAvailable);
    }

    private static TestMethod void isBatchSlotAvailable_JobQueued() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);
        Integer numberOfJobsQueued = 10;
        Test.enqueueBatchJobs(numberOfJobsQueued);

        Boolean isBatchSlotAvailable = bLimitService.isBatchSlotAvailable(batchSlotsTotalCount - numberOfJobsQueued);

        System.assert(isBatchSlotAvailable);
    }

    private static TestMethod void isBatchSlotAvailable_TooMany() {
        bLimitService = new loli_utils_LimitManager(batchQueuedSlotsCount);
        Integer numberOfJobsQueued = 10;
        Test.enqueueBatchJobs(numberOfJobsQueued);

        Boolean isBatchSlotAvailable = bLimitService.isBatchSlotAvailable(batchSlotsTotalCount);

        System.assert(!isBatchSlotAvailable);
    }


    //----------------------------- getAvailableScheduleSlots ----------------------------------//

    //---- Happy path ----//

    private static TestMethod void getAvailableScheduleSlots() {
        bLimitService = new loli_utils_LimitManager();

        Integer calculatedNumberOfSlots = bLimitService.getAvailableScheduleSlots();

        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(scheduledJobsCount, calculatedNumberOfSlots);
    }

    private static TestMethod void getAvailableScheduleSlots_JobScheduled() {
        bLimitService = new loli_utils_LimitManager();
        Integer testYear = Date.today().year() + 1;

        Test.startTest();
        System.schedule('testJob', '0 0 0 3 12 ? ' + testYear, new loli_utils_ScheduleStub());
        Integer calculatedNumberOfSlots = bLimitService.getAvailableScheduleSlots();

        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(scheduledJobsCount - 1, calculatedNumberOfSlots);
        Test.stopTest();
    }

    private static void getAvailableScheduleSlots_JobCompleted() {
        bLimitService = new loli_utils_LimitManager();
        Integer testYear = Date.today().year() + 1;

        Test.startTest();
        System.schedule('testJob', '0 0 0 3 12 ? ' + testYear, new loli_utils_ScheduleStub());
        Test.stopTest();

        Integer calculatedNumberOfSlots = bLimitService.getAvailableScheduleSlots();
        System.assert(calculatedNumberOfSlots != null);
        System.assertEquals(scheduledJobsCount, calculatedNumberOfSlots);
    }


    //----------------------------- isScheduleSlotAvailable ----------------------------------//

    //---- Happy path ----//

    private static TestMethod void isScheduleSlotAvailable() {
        bLimitService = new loli_utils_LimitManager();

        Boolean isScheduleSlotAvailable = bLimitService.isScheduleSlotAvailable(scheduledJobsCount);

        System.assert(isScheduleSlotAvailable);
    }

    private static TestMethod void isScheduleSlotAvailable_JobScheduled() {
        bLimitService = new loli_utils_LimitManager();
        Integer testYear = Date.today().year() + 1;

        Test.startTest();
        System.schedule('testJob', '0 0 0 3 12 ? ' + testYear, new loli_utils_ScheduleStub());
        Boolean isScheduleSlotAvailable = bLimitService.isScheduleSlotAvailable(scheduledJobsCount - 1);

        System.assert(isScheduleSlotAvailable);
        Test.stopTest();
    }

    private static void isScheduleSlotAvailable_JobCompleted() {
        bLimitService = new loli_utils_LimitManager();
        Integer testYear = Date.today().year() + 1;

        Test.startTest();
        System.schedule('testJob', '0 0 0 3 12 ? ' + testYear, new loli_utils_ScheduleStub());
        Test.stopTest();

        Boolean isScheduleSlotAvailable = bLimitService.isScheduleSlotAvailable(scheduledJobsCount);

        System.assert(isScheduleSlotAvailable);
    }

    private static TestMethod void isScheduleSlotAvailable_TooMany() {
        bLimitService = new loli_utils_LimitManager();

        Boolean isScheduleSlotAvailable = bLimitService.isScheduleSlotAvailable(scheduledJobsCount + 1);

        System.assertEquals(false, isScheduleSlotAvailable);
    }

    //----------------------------- isScheduleNameAvailable ----------------------------------//

    //---- Happy Path ----//

    private static TestMethod void isScheduleNameAvailable_Scheduled() {
        Schedulable testSchedule = new loli_utils_ScheduleStub();
        String name = 'testScheduler';
        String croneDefinition = '0 0 * * * ? *';
        loli_utils_IPlatform platformService = new loli_utils_PlatformManager();
        loli_utils_IPlatformLimit platformLimtService = new loli_utils_LimitManager();

        Test.startTest();
        platformService.schedule(name, croneDefinition, testSchedule);
        Test.stopTest();

        Boolean isNameAvailable = platformLimtService.isScheduleNameAvailable(name);
        System.assert(!isNameAvailable);
    }

    private static TestMethod void isScheduleNameAvailable_Not_Scheduled() {
        String name = 'testScheduler';
        loli_utils_IPlatformLimit platformLimtService = new loli_utils_LimitManager();

        Boolean isNameAvailable = platformLimtService.isScheduleNameAvailable(name);
        System.assert(isNameAvailable);
    }

}