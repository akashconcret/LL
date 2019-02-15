/**
 * PlatformService implementation
 */
public with sharing class loli_utils_PlatformManager implements loli_utils_IPlatform {

    public Object newInstance(String className) {
        Type objectType = Type.forName(className);
        if (objectType == null) {
            return null;
        }

        try {
            return objectType.newInstance();
        } catch (Exception e) {
            return null;
        }

    }

    public Id executeBatch(Database.Batchable<Object> batchObject, Integer scope) {
        return Database.executeBatch(batchObject, scope);
    }

    public Id schedule(String name, String cronDefinition, Schedulable scheduler) {
        return System.schedule(name, cronDefinition, scheduler);
    }

    public void abortJob(Id jobId) {
        System.abortJob(jobId);
    }

    public List<sObject> query(String queryString) {
        return Database.query(queryString);
    }

}