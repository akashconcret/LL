/**
 * Utils related mocks
 */

public with sharing class loli_utils_Mocks {

    public class PlatformLimitMock extends loli_mock_MockBase implements loli_utils_IPlatformLimit {


        public Integer getAvailableBatchSlots() {
            return (Integer) super.doInvocation('getAvailableBatchSlots');
        }

        public Boolean isBatchSlotAvailable(Integer requestedSlotsCount) {
            return (Boolean) super.doInvocation('isBatchSlotAvailable', new List<Object> {requestedSlotsCount});
        }


        public Integer getAvailableScheduleSlots() {
            return (Integer) super.doInvocation('getAvailableScheduleSlots');
        }


        public Boolean isScheduleSlotAvailable(Integer requestedSlotsCount) {
            return (Boolean) super.doInvocation('isScheduleSlotAvailable', new List<Object> {requestedSlotsCount});
        }


        public Boolean isScheduleNameAvailable(String scheduleName) {
            return (Boolean) super.doInvocation('isScheduleNameAvailable', new List<Object> {scheduleName});
        }

    }

    public class PlatformMock extends loli_mock_MockBase implements loli_utils_IPlatform {


        public Object newInstance(String className) {
            return super.doInvocation('newInstance', new List<Object> {className});
        }


        public Id executeBatch(Database.Batchable<Object> batchObject, Integer scope) {
            return (Id) super.doInvocation('executeBatch', new List<Object> {batchObject, scope});
        }


        public Id schedule(String name, String cronDefinition, Schedulable scheduler) {
            return (Id) super.doInvocation('schedule', new List<Object> {name, cronDefinition, scheduler});
        }

        public void abortJob(Id jobId) {
            super.doInvocation('abortJob', new List<Object> {jobId});
        }

        public List<sObject> query(String queryString) {
            return (List<sObject>) super.doInvocation('query', new List<Object> {queryString});
        }

    }

    public class FlsCheckMock extends loli_mock_MockBase implements loli_utils_IFLSCheck {
        public void checkWithException(loli_utils_Enum.FlsType flsType) {
            super.doInvocation('checkWithException', new List<Object> {flsType});
        }

        public Boolean check(loli_utils_Enum.FlsType flsType) {
            return (Boolean) super.doInvocation('check', new List<Object> {flsType});
        }

        public void replaceWithNull(loli_utils_Enum.FlsType flsType) {
            super.doInvocation('replaceWithNull', new List<Object> {flsType});
        }
    }

}