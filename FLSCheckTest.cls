@isTest
public with sharing class FLSCheckTest {
	public FLSCheckTest() {
		
	}

    private static FLSCheck flsCheck;


    //---- checkWithException ----//

    private static Integer objectCount_checkWithException = 6;
    private static List<SObject> accountList_checkWithException;
    private static List<SObject> opportunityList_checkWithException;

    private static void setupCheckWithException() {
        accountList_checkWithException = prepareSObject(new Account(), objectCount_checkWithException);
        opportunityList_checkWithException = prepareSObject(
        	new Opportunity(StageName = 'test', CloseDate = Date.today()), objectCount_checkWithException);
    }


    private static TestMethod void doesNotThrowWhenFlsTypeIsFulfilled() {
        setupCheckWithException();
        flsCheck = new FLSCheck(accountList_checkWithException);

        try {
            flsCheck.checkWithException();
        } catch (Exception e) {
            System.assert(false);
        }
    }

    private static TestMethod void doesNotThrowWhenFlsTypeIsFulfilledForAListWithDifferentObjectTypes() {
        setupCheckWithException();
        List<SObject> sobjectList = new List<SObject>();
        sobjectList.addall(accountList_checkWithException);
        sobjectList.addall(opportunityList_checkWithException);
        flsCheck = new FLSCheck(sobjectList);

        try {
            flsCheck.checkWithException();
        } catch (Exception e) {
            System.assert(false);
        }
    }

    private static TestMethod void doesNotThrowWhenProvidedListIsEmpty() {
        setupCheckWithException();
        flsCheck = new FLSCheck(new List<SObject>());

        try {
            flsCheck.checkWithException();
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
        flsCheck = new FLSCheck(accountList_check);


        Boolean isCheck = flsCheck.check();

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
        flsCheck = new FLSCheck(accountList_replaceWithNull);


        flsCheck.replaceWithNull();

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