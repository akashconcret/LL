public with sharing class loli_utils_SFObjectFLSCheck implements loli_utils_IFLSCheck {

    private enum FieldType {
        parent, relationship, normal
    }


    private Map<String, Object> querriedObjectFields;
    private SObject objectToCheck;
    private Map<String, SObjectField> fieldDescribeMap;

    public loli_utils_SFObjectFLSCheck(SObject objectToCheck) {
        this.objectToCheck = objectToCheck;
        this.querriedObjectFields = objectToCheck.getPopulatedFieldsAsMap();
        fieldDescribeMap = objectToCheck.getSObjectType().getDescribe().fields.getMap();
    }


    public void checkWithException(loli_utils_Enum.FlsType flsType) {
        system.debug('fieldNameLoop . :: '+querriedObjectFields.keySet());
        for (String fieldNameLoop : querriedObjectFields.keySet()) {
            system.debug('checkFieldPermission . :: '+isFLSTypeFulfilledForField(fieldNameLoop, flsType));
            if (!isFLSTypeFulfilledForField(fieldNameLoop, flsType)) {
                throw new loli_utils_Exceptions.AccessTypeViolatedException();
            }
        }
    }

    public Boolean check(loli_utils_Enum.FlsType flsType) {
        for (String fieldNameLoop : querriedObjectFields.keySet()) {
            if (!isFLSTypeFulfilledForField(fieldNameLoop, flsType)) {
                return false;
            }
        }
        return true;
    }


    public void replaceWithNull(loli_utils_Enum.FlsType flsType) {
        for (String fieldNameLoop : querriedObjectFields.keySet()) {
            if (!isFLSTypeFulfilledForField(fieldNameLoop, flsType)) {
                objectToCheck.put(fieldNameLoop, null);
            }
        }
    }

    /**
     * Checks if the fls type is fulfilled for the field by the current user
     */
    private Boolean isFLSTypeFulfilledForField(String fieldName, loli_utils_Enum.FlsType flsType) {
        SObjectField field = fieldDescribeMap.get(fieldName);
        FieldType fType = getFieldType(fieldName);
        
        // In case field is not supported by field describe, throw an exception
        if (field == null && fType == FieldType.normal) {
            throw new loli_utils_Exceptions.QueryNotSupportedException();
        }

        // In case of standard field check accessibility
        if (fType == FieldType.normal) {
            DescribeFieldResult fieldDescribe = field.getDescribe();
            if (loli_utils_Enum.FLSType.access == flsType) {
                return fieldDescribe.isAccessible();
            } else {
                return false;
            }
        } else if (FieldType.parent == fType) {
            // In case of relationsship field recursivly check accessibility in parent
            SObject parent = ((SObject)querriedObjectFields.get(fieldName));
            return new loli_utils_SFObjectFLSCheck(parent).check(flsType);
        } else if (FieldType.relationship == fType) {
            // In case of relationship query check for childs
            List<SObject> childs = ((List<SObject>) querriedObjectFields.get(fieldName));
            return new loli_utils_SFObjectListFLSCheck(childs).check(flsType);
        } else {
            throw new loli_utils_Exceptions.QueryNotSupportedException();
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