public with sharing class FLSCheck implements IFLSCheck {

    public interface IFLSCheck {

        /**
         * Checks the provided sObject for the provided flsType
         * Throws an exception in case flsType is not fulfilled
         */
        void checkWithException();

        /**
         * Checks the provided sObject for the provided flsType
         * Returns true when fulfilled, false otherwise
         */
        Boolean check();


        /**
         * Replaces all fields that do not fulfill the provided flsType with null
         */
        void replaceWithNull();

    }
    
    public class AccessTypeViolatedException extends Exception {}
    public class QueryNotSupportedException extends Exception {}
  
    public enum FLSType { access }
    public enum FieldType { parent, relationship, normal }

    private final List<SObject> sObjs = new List<SObject>();

    public FLSCheck(List<SObject> sObjs) {
    	this.sObjs.addAll(sObjs);
    }

    public void checkWithException() {
        for (SObject sObj : sObjs) {
            new FLSObjectCheck(sObj).checkWithException();
        }
    }

    public Boolean check() {
        for (SObject sObj : sObjs) {
            if (!new FLSObjectCheck(sObj).check()) {
                return false;
            }
        }
        return true;
    }


    public void replaceWithNull() {
        for (SObject sObj : sObjs) {
            new FLSObjectCheck(sObj).replaceWithNull();
        }
    }  

    private class FLSObjectCheck implements IFLSCheck {
	    private final Map<String, Object> querriedObjectFields;
	    private final SObject objectToCheck;
	    private final Map<String, SObjectField> fieldDescribeMap;

    	private FLSObjectCheck(SObject sObj) {
	        this.objectToCheck = sObj;
	        this.querriedObjectFields = sObj.getPopulatedFieldsAsMap();
	        this.fieldDescribeMap = sObj.getSObjectType().getDescribe().fields.getMap();
    	}

	    public void checkWithException() {
	        for (String fieldNameLoop : querriedObjectFields.keySet()) {
	            if (!isFLSTypeFulfilledForField(fieldNameLoop)) {
	                throw new AccessTypeViolatedException();
	            }
	        }
	    }

	    public Boolean check() {
	        for (String fieldNameLoop : querriedObjectFields.keySet()) {
	            if (!isFLSTypeFulfilledForField(fieldNameLoop)) {
	                return false;
	            }
	        }
	        return true;
	    }


	    public void replaceWithNull() {
	        for (String fieldNameLoop : querriedObjectFields.keySet()) {
	            if (!isFLSTypeFulfilledForField(fieldNameLoop)) {
	                objectToCheck.put(fieldNameLoop, null);
	            }
	        }
	    }

	    /**
	     * Checks if the fls type is fulfilled for the field by the current user
	     */
	    private Boolean isFLSTypeFulfilledForField(String fieldName) {
	    	final FlsType accessFlsType = FlsType.access;

	        SObjectField field = fieldDescribeMap.get(fieldName);
	        FieldType fType = getFieldType(fieldName);
	        // In case field is not supported by field describe, throw an exception
	        if (field == null && fType == FieldType.normal) {
	            throw new QueryNotSupportedException();
	        }

	        // In case of standard field check accessibility
	        if (fType == FieldType.normal) {
	            DescribeFieldResult fieldDescribe = field.getDescribe();
	            if (FLSType.access == accessFlsType) {
	                return fieldDescribe.isAccessible();
	            } else {
	                return false;
	            }
	        } else if (FieldType.parent == fType) {
	            // In case of relationsship field recursivly check accessibility in parent
	            SObject parent = ((SObject)querriedObjectFields.get(fieldName));
	            return new FLSObjectCHeck(parent).check();
	        } else if (FieldType.relationship == fType) {
	            // In case of relationship query check for childs
	            List<SObject> childs = ((List<SObject>) querriedObjectFields.get(fieldName));
	            return new FLSCheck(childs).check();
	        } else {
	            throw new QueryNotSupportedException();
	        }
	    }

	    /**
	     * Returns the field type of field based on the PopulatedFieldsMap
	     */
	    private FieldType getFieldType(String fieldname) {
	        // Order is important here as for some unknown reason "List<SObject>" is also instanceof "SObject"
	        // but later throws an exception during conversion
	        if (querriedObjectFields.get(fieldname) instanceof List<SObject>) {
	            return FieldType.relationship;
	        } else if (querriedObjectFields.get(fieldname) instanceof SObject) {
	            return FieldType.parent;
	        } else {
	            return FieldType.normal;
	        }
	    }
    }
}