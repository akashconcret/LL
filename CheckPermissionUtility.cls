public class CheckPermissionUtility {
    public static DescribeSObjectResult getDescribeSObjectResult(String objectName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe();
    }
    public static DescribeFieldResult getDescribeFieldResult(DescribeSObjectResult obj, String fieldName){
        return obj.fields.getMap().get(fieldName).getDescribe();
    }
    public static Boolean checkAllPermissionsField(DescribeFieldResult dfr){
        return (dfr.isAccessible() && dfr.isCreateable());
    }
    public static Boolean checkSomePermissionsField(DescribeFieldResult dfr){
        return (dfr.isAccessible() && dfr.isUpdateable());
    }
    public static Boolean checkAllPermissionsObject(DescribeSObjectResult dsr){
        return (dsr.isAccessible() && dsr.isCreateable() && dsr.isUpdateable() && dsr.isQueryable());
    }
    public static Boolean checkSomePermissionsObject(DescribeSObjectResult dsr){
        return (dsr.isAccessible() && dsr.isQueryable());
    }
}