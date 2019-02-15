@isTest
public with sharing class loli_utils_SFObjectListFLSCheckTest {

    private static loli_utils_SFObjectListFLSCheck flsCheck;


    //---- checkWithException ----//

    private static Integer objectCount_checkWithException = 6;
    private static List<SObject> accountList_checkWithException;
    private static List<SObject> opportunityList_checkWithException;

    private static void setupCheckWithException() {
        accountList_checkWithException = prepareSObject(new Account(), objectCount_checkWithException);
        opportunityList_checkWithException = prepareSObject(new Opportunity(StageName = 'test', CloseDate = Date.today()), objectCount_checkWithException);
    }


    private static TestMethod void doesNotThrowWhenFlsTypeIsFulfilled() {
        setupCheckWithException();
        flsCheck = new loli_utils_SFObjectListFLSCheck(accountList_checkWithException);

        try {
            flsCheck.checkWithException(loli_utils_Enum.FLSType.access);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    private static TestMethod void doesNotThrowWhenFlsTypeIsFulfilledForAListWithDifferentObjectTypes() {
        setupCheckWithException();
        List<SObject> sobjectList = new List<SObject>();
        sobjectList.addall(accountList_checkWithException);
        sobjectList.addall(opportunityList_checkWithException);
        flsCheck = new loli_utils_SFObjectListFLSCheck(sobjectList);

        try {
            flsCheck.checkWithException(loli_utils_Enum.FLSType.access);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    private static TestMethod void doesNotThrowWhenProvidedListIsEmpty() {
        setupCheckWithException();
        flsCheck = new loli_utils_SFObjectListFLSCheck(new List<SObject>());

        try {
            flsCheck.checkWithException(loli_utils_Enum.FLSType.access);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    //---- check ----//

    private static Integer objectCount_check = 6;
    private static List<SObject> accountList_check;
    private static List<SObject> opportunityList_check;

    private static void setupCheck() {
        accountList_check = prepareSObject(new Account(), objectCount_check);
        opportunityList_check = prepareSObject(new Opportunity(StageName = 'test', CloseDate = Date.today()), objectCount_check);
    }


    private static TestMethod void returnsTrueWhenFlsAccessIsFulfilled() {
        setupCheck();
        flsCheck = new loli_utils_SFObjectListFLSCheck(accountList_check);


        Boolean isCheck = flsCheck.check(loli_utils_Enum.FLSType.access);

        System.assert(isCheck != null);
        System.assert(isCheck);

    }


    //---- replaceWithNull ----//

    private static Integer objectCount_replaceWithNull = 6;
    private static List<SObject> accountList_replaceWithNull;
    private static List<SObject> opportunityList_replaceWithNull;

    private static void setupReplaceWithNull() {
        accountList_replaceWithNull = prepareSObject(new Account(), objectCount_replaceWithNull);
        opportunityList_replaceWithNull = prepareSObject(new Opportunity(StageName = 'test', CloseDate = Date.today()), objectCount_replaceWithNull);
    }


    private static TestMethod void doesNotReplaceWhenFlsTypeisFulfilled() {
        setupReplaceWithNull();
        flsCheck = new loli_utils_SFObjectListFLSCheck(accountList_replaceWithNull);


        flsCheck.replaceWithNull(loli_utils_Enum.FLSType.access);

        for (SObject accountLoop : accountList_replaceWithNull) {
            System.assert(String.isNotEmpty((String) accountLoop.get('Name')));
        }
    }

    //---- Utils ----//

    private static List<SObject> prepareSObject(SObject template, Integer sObjectCount) {
        List<SObject> sObjectList = new List<SObject>();
        for (Integer sObjectIndex = 0; sObjectIndex < sObjectCount; sObjectIndex++) {
            SObject newSObject = template.clone(false, true);
            newSObject.put('Name', 'test' + sObjectIndex);
            sObjectList.add(newSObject);
        }
        return sObjectList;
    }

}