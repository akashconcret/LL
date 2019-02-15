//Called from PostInstall, so needs without sharing permissions on startup
public class LeadWebQueueHandler implements  SfQueueHandler {
    DescribeSObjectResult desResultObj = CheckPermissionUtility.getDescribeSObjectResult('QueueSobject');
    DescribeFieldResult desResultFieldQueueId = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'QueueId');
    DescribeFieldResult desResultFieldSObjectType = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'SObjectType');
    public Enum GroupType {
        Queue
    }

    public void checkAndCreateSfQueues() {
        try{
            createQueues();
            // createSObjectTypesForQueues(leadWebQeuesById);
            // addAdminsToQueues(leadWebQeuesById);
            // System.debug('Success:: '+ String.valueOf(leadWebQeuesById));
        }catch(exception ex){
            System.debug('Errror:: '+'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
    }
    /**
     * Creates leadweb queues in case these do not already exists
     * Existence is determined based on Queues developer name
     */
    public void createQueues() {
        Map<String, Group> leadWebQueues = new Map<String, Group>();
        for(Group queue : [Select Id, Name, DeveloperName, Type From Group Where (DeveloperName =: Constants.LeadQueueName Or
                          DeveloperName =: Constants.CompanyQueueName) And Type =: GroupType.Queue.name()]) {
            leadWebQueues.put(queue.DeveloperName, queue);
        }
        
        Group leadQueue = new Group();
        if(leadWebQueues.containsKey(Constants.LeadQueueName)){
            leadQueue = leadWebQueues.get(Constants.LeadQueueName);
        }else{
            leadQueue = checkAndCreateGroup(Constants.LeadQueueName, Constants.LeadQueue);
            if(leadQueue!=null && leadQueue.getSObjectType().getDescribe().iscreateable()){
                insert leadQueue; 
            }
        } 
        
        Group companyQueue = new Group();
        if(leadWebQueues.containsKey(Constants.CompanyQueueName)){
            companyQueue = leadWebQueues.get(Constants.CompanyQueueName);
        }else{
            companyQueue = checkAndCreateGroup(Constants.CompanyQueueName, Constants.CompanyQueue);
            if(companyQueue!=null && companyQueue.getSObjectType().getDescribe().iscreateable()){
                insert companyQueue;  
            }
        }
        
        QueueSobject sobjLeadQueue = createLeadQueue(leadQueue);
        if(sobjLeadQueue!=null && sobjLeadQueue.getSObjectType().getDescribe().iscreateable()){
            upsert sobjLeadQueue;
        }
        
        QueueSobject sobjCompQueue = createCompanyQueue(companyQueue);
        if(sobjCompQueue!=null && sobjCompQueue.getSObjectType().getDescribe().iscreateable()){
            upsert sobjCompQueue; 
        } 
        
        List<User> lstAdmins = [Select Id, Name From User Where Profile.Name = : Constants.AdminProfileName_EN Or Profile.Name = : Constants.AdminProfileName_DE];
        List<GroupMember> members = new List<GroupMember>();
        DescribeSObjectResult desResultObj = CheckPermissionUtility.getDescribeSObjectResult('GroupMember');
        DescribeFieldResult desResultFieldGroupId = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'GroupId');
        DescribeFieldResult desResultFielduserOrGroupId = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'userorGroupId');
        for(User admin : lstAdmins) {
            if(members!=null && desResultObj.isCreateable() && CheckPermissionUtility.checkAllPermissionsField(desResultFieldGroupId)
                    && CheckPermissionUtility.checkAllPermissionsField(desResultFielduserOrGroupId)){
                members.add(new GroupMember(GroupId = leadQueue.Id, userOrGroupId = admin.Id));
            }
        }
        for(User admin : lstAdmins) {
            if(members!=null && desResultObj.isCreateable() && CheckPermissionUtility.checkAllPermissionsField(desResultFieldGroupId)
                    && CheckPermissionUtility.checkAllPermissionsField(desResultFielduserOrGroupId)){
                members.add(new GroupMember(GroupId = companyQueue.Id, userOrGroupId = admin.Id));
            }
        }
        if(members!=null && members.size()>0 && members[0].getSObjectType().getDescribe().isCreateable()){
            upsert members; 
        }
    }

    /**
     * Creates a new queue/group in case it does not already exist
     */
    public Group checkAndCreateGroup(String queueName, String queueLabel) {
        DescribeSObjectResult desResultObj = CheckPermissionUtility.getDescribeSObjectResult('Group');
        DescribeFieldResult desResultFieldDeveloperName = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'DeveloperName');
        DescribeFieldResult desResultName = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'Name');
        DescribeFieldResult desResultType = CheckPermissionUtility.getDescribeFieldResult(desResultObj,'Type');
        
        if(desResultObj.iscreateable() && CheckPermissionUtility.checkAllPermissionsField(desResultFieldDeveloperName) &&
            CheckPermissionUtility.checkAllPermissionsField(desResultName) && CheckPermissionUtility.checkAllPermissionsField(desResultType)){
            Group jobQueue = new Group(DeveloperName = queueName, Name = queueLabel, Type = GroupType.Queue.name());
            return jobQueue;
        }
        return null;
    }

    /**
     * Associates the lead web queues with their SObjectType in case it is not already associated
     */
    
    public QueueSobject createCompanyQueue(Group jobQueue) {
        if(desResultObj.isCreateable() && CheckPermissionUtility.checkAllPermissionsField(desResultFieldQueueId)
                    && CheckPermissionUtility.checkAllPermissionsField(desResultFieldSObjectType)){
                        
            QueueSobject sobjQueue = new QueueSobject(QueueId = jobQueue.Id, SObjectType = WMLL__Company__c.getSObjectType().getDescribe().getName());
            return sobjQueue;
        }
        return null;
    }
    
    public QueueSobject createLeadQueue(Group jobQueue) {
        if(desResultObj.isCreateable() && CheckPermissionUtility.checkAllPermissionsField(desResultFieldQueueId)
                    && CheckPermissionUtility.checkAllPermissionsField(desResultFieldSObjectType)){
            QueueSobject sobjQueue = new QueueSobject(QueueId = jobQueue.Id, SObjectType = Lead.getSObjectType().getDescribe().getName());
            return sobjQueue;
        }
        return null;
    }
    /**
     * Creates the association between a lead web queues and an sObjectType
     */
    private QueueSobject createQueueSobject(Group groupofQueuesSObjectType) {
        if (Constants.LeadQueueName.equals(groupofQueuesSObjectType.DeveloperName)) {
            return new QueueSobject(QueueId = groupofQueuesSObjectType.Id, SObjectType = Lead.getSObjectType().getDescribe().getName());
        } else if (Constants.CompanyQueueName.equals(groupofQueuesSObjectType.DeveloperName)) {
            return new QueueSobject(QueueId = groupofQueuesSObjectType.Id, SObjectType = WMLL__Company__c.getSObjectType().getDescribe().getName());
        } else {
            return null;
        }
    }
 
    /**
     * Associates admins with the given queues
     */
    private void addAdminsToQueues(Map<Id, Group> leadWebQueuesById) {
        final Map<Id, User> admins = new Map<Id, User>([Select Id, Name From User
        Where Profile.Name = : Constants.AdminProfileName_EN Or
        Profile.Name = : Constants.AdminProfileName_DE]);

        final List<GroupMember> members = new List<GroupMember>();

        for(User admin : admins.values()) {
            for(Group queue : leadWebQueuesById.values())
                members.add(new GroupMember(GroupId = queue.Id, userOrGroupId = admin.Id));
        }
		DMLManager.insertAsSystem(members);
    }
    

}