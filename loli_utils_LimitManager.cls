/**
 * Class contains utils for managing sf batch status and limitations
 */
public with sharing class loli_utils_LimitManager implements loli_utils_IPlatformLimit {

    private static final Integer scheduleQueuableSlotsCount = 99;
    private static final Integer batchHoldingSlotsCount = 99;
    private static final Integer batchQueuableSlotsCountDefault = 5;

    private Integer batchSlotsCount;


    public loli_utils_LimitManager() {
        this.batchSlotsCount = batchHoldingSlotsCount + batchQueuableSlotsCountDefault;
    }

    public loli_utils_LimitManager(Integer batchQueuableSlotsCount) {
        this.batchSlotsCount = batchHoldingSlotsCount + batchQueuableSlotsCount;
    }

    public Integer getAvailableBatchSlots() {
        Integer batchJobsCount = [SELECT Count() FROM AsyncApexJob WHERE
        JobType = :loli_utils_AsyncApexEnums.AsyncApexType.BatchApex.name() AND
        (Status = :loli_utils_AsyncApexEnums.AsyncApexStatus.Holding.name() OR Status = :loli_utils_AsyncApexEnums.AsyncApexStatus.Queued.name())];

        Integer availableSlotsCount = batchSlotsCount - batchJobsCount;

        return availableSlotsCount;
    }

    public Boolean isBatchSlotAvailable(Integer requestedSlotsCount) {
        return requestedSlotsCount <= getAvailableBatchSlots();
    }

    public Integer getAvailableScheduleSlots() {
        Integer scheduledJobsCount = [SELECT Count() FROM AsyncApexJob WHERE
        JobType = :loli_utils_AsyncApexEnums.AsyncApexType.ScheduledApex.name() AND (Status = :loli_utils_AsyncApexEnums.AsyncApexStatus.Queued.name() OR
            Status = :loli_utils_AsyncApexEnums.AsyncApexStatus.Preparing.name() OR
            Status = :loli_utils_AsyncApexEnums.AsyncApexStatus.Processing.name())];
        return scheduleQueuableSlotsCount - scheduledJobsCount;
    }

    public Boolean isScheduleSlotAvailable(Integer requestedSlotsCount) {
        return requestedSlotsCount <= getAvailableScheduleSlots();
    }

    public Boolean isScheduleNameAvailable(String scheduleName) {
        Integer scheduledMatches = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :scheduleName];

        return scheduledMatches == 0;
    }

}