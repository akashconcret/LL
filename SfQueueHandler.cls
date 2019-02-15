/**
 * Created by Mathias on 26.07.16.
 */

public interface SfQueueHandler {

    /**
     * Checks for the required queues and creates/updates them if not existing
     */
    void checkAndCreateSfQueues();

}