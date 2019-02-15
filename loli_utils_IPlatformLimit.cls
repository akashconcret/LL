/**
 * Salesforce limit related operations
 */
public interface loli_utils_IPlatformLimit {


    /**
     * Determines the number of currently available batch slots
     */
    Integer getAvailableBatchSlots();
    /**
     * Checks if the requested number of batch slots are available
     */
    Boolean isBatchSlotAvailable(Integer requestedSlotsCount);

    /**
     * Determines the number of currently available schedule slots
     */
    Integer getAvailableScheduleSlots();

    /**
     * Checks if the number of requested schedule slots is available
     */
    Boolean isScheduleSlotAvailable(Integer requestedSlotsCount);

    /**
     * Checks if the schedule name is available
     */
    Boolean isScheduleNameAvailable(String scheduleName);

}