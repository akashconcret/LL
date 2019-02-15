/**
 * Created by Mathias on 03.02.16.
 */

public with sharing class loli_utils_AsyncApexEnums {

    public enum AsyncApexType {
        BatchApex, ScheduledApex
    }

    public enum AsyncApexStatus {
        Holding, Queued, Preparing, Processing
    }

    public enum CronTriggerStatus {
        WAITING, ACQUIRED, EXECUTING, COMPLETE, ERROR, DELETED, PAUSED, BLOCKED, PAUSED_BLOCKED
    }

    public static AsyncApexType asyncApexTypeFromString(String asyncApexTypeString) {
        for (AsyncApexType aaTypeLoop : AsyncApexType.values()) {
            if (aaTypeLoop.name().equals(asyncApexTypeString)) {
                return aaTypeLoop;
            }
        }
        return null;
    }

    public static AsyncApexStatus asyncApexStatusFromString(String asyncApexStatusString) {
        for (AsyncApexStatus aaStatusLoop : AsyncApexStatus.values()) {
            if (aaStatusLoop.name().equals(asyncApexStatusString)) {
                return aaStatusLoop;
            }
        }
        return null;
    }


    public static CronTriggerStatus cronTriggerStatusFromString(String cronTriggerStatusString) {
        for (CronTriggerStatus ctStatusLoop : CronTriggerStatus.values()) {
            if (ctStatusLoop.name().equals(cronTriggerStatusString)) {
                return ctStatusLoop;
            }
        }
        return null;
    }

}