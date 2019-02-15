/**
 * Bulk handling of tasks.
 */
public with sharing class TaskManager {
    private Map<String, Task> tasks = new Map<String, Task>();
    private Setting__c settings = null;
    private User stdUserRef = null;

    public TaskManager() {
        settings = Setting__c.getValues(Constants.CUSTOM_SETTING_NAME);

        if(settings != null) {
            String stdUsername = settings.StandardTaskUser__c;
            List<User> users = [Select Id from User where Name = :stdUsername limit 1];
            //if stdUsername could not be match with actual user, use current user as stdUser
            if(users.isEmpty())
                stdUserRef = [Select Id from User where Id = :UserInfo.getUserId() limit 1].get(
                                 0);
            else
                stdUserRef = users.get(0);
        }
    }

    /**
     * Setup a task for a lead.
     * Don't write directly to the database, instead wait for write tasks to be
     * called.
     */
    public void createTaskForBatch(Visit__c visit) {
        Task newTask = createTask(new list<Visit__c>{visit});
        tasks.put(newTask.WhatId, newTask);
    }

    /**
     * @return A task setup for a lead with manual accounts and contacts
     */
    public Task createTask(list<Visit__c> visit) {
        Task task = new Task();

        //if no user assigned, use account owner. if no account owner exists, use standard user from settings
        Account acc = [Select Id,
                      OwnerId from Account where Id = :visit[0].Account__c];
        if(visit[0].AssignedUser__c != null)
            task.OwnerId = visit[0].AssignedUser__c;
        else if(settings.AccountOwnerIsTaskOwner__c && acc != null)
            task.OwnerId = acc.OwnerId;
        else
            task.OwnerId = stdUserRef.Id;
        //account
        task.WhatId = visit[0].Account__c;
        //contact
        task.WhoId = visit[0].Contact__c;

        task = putCommonInfo(visit[0], task);

        return task;
    }

    /**
     * Setup a task for a known lead.
     * Don't write directly to the database, instead wait for write tasks to be
     * called.
     *
     * @return: A new task matched with a known account and contact
     */
    public Task createTaskForMatchForBatch(Visit__c visit, Account acc) {
        Task task = new Task();

        //mapping of properties
        //user to which task is assigned to
        if(settings.AccountOwnerIsTaskOwner__c)
            task.OwnerId = acc.OwnerId;
        else
            task.OwnerId = stdUserRef.Id;

        //account
        task.WhatId = acc.Id;
        //contact
        task.WhoId = matchContactWithAccount(acc);

        task = putCommonInfo(visit, task);

        tasks.put(task.WhatId, task);
        return task;
    }

    /**
     * Add information to a task regarding a visit.
     */
    private Task putCommonInfo(Visit__c visit, Task task) {
        // task.IsTask__c = true;

        task.Subject = 'Call';
        task.Priority = 'Normal';

        Date duedate = visit.Datetime__c.date();
        duedate = duedate.addDays(settings.TimeUntilDuedate__c.intValue());
        task.ActivityDate = duedate;

        return task;
    }

    /**
     * Get the contact Id for an account
     */
    private String matchContactWithAccount(Account acc) {
        if(acc.Contacts.size() == 1)
            return acc.Contacts.get(0).Id;
        else
            return null;
    }

    /**
     * Writes the created tasks. Only creates one task per account. If there is already a task for an account, do not create a new one.
     */
    public Boolean writeTasksBatch() {
        List<Task> tasksToInsert = tasks.values();

        try {
            List<Task> exisitingTasks = [Select WhatId from Task];

            //delete duplicates
            for(Integer i = 0; i < tasksToInsert.size(); i++) {
                if(checkForDuplicate(tasksToInsert.get(i), exisitingTasks))
                    tasksToInsert.remove(i);
            }

            insert tasksToInsert;
        } catch(DmlException e) {
            return false;
        }

        return true;
    }

    /**
     * Clear the task list.
     */
    public void clear() {
        if(tasks != null)
            tasks.clear();
    }

    /**
     * Check if there is already an existing task for the same account.
     */
    private Boolean checkForDuplicate(Task t1, List<Task> exisitingTasks) {
        for(Task existingTask : exisitingTasks) {
            if(t1.WhatId == existingTask.WhatId)
                return true;
        }

        return false;
    }
}