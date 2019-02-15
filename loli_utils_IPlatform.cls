/**
 * Contains definitions related to the salesforce platform
 */
public interface loli_utils_IPlatform {


    /**
     * Creates a new instance of the provided class
     * Returns null in case the class does not exist
     */
    Object newInstance(String className);


    /**
     * Executes the given batchable with provided scope size
     */
    Id executeBatch(Database.Batchable<Object> batchObject, Integer scope);

    /**
     * Starts the given scheduleable
     */
    Id schedule(String name, String cronDefinition, Schedulable scheduler);

    /**
     * Aborts the scheduler with the given Id
     */
    void abortJob(Id jobId);

    /**
     * Executes a dynamic soql query
     */
    List<sObject> query(String queryString);



}