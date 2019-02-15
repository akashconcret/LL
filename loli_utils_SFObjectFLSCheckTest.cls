@isTest
public with sharing class loli_utils_SFObjectFLSCheckTest {

    private static final String testAccountName = 'test';
    private static final String testContactName = 'test';

    private static Account testAccount;
    private static Contact testContact;
    private static Account testAccountWithRelationship;
    private static loli_utils_SFObjectFLSCheck flsCheck;

    private static void setup() {
        testAccount = new Account(Name = testAccountName);
        insert testAccount;
        testContact = new Contact(LastName = testContactName, AccountId = testAccount.Id);
        insert testContact;
        testAccount = [SELECT Id, Name, LastModifiedDate FROM Account WHERE ID = :testAccount.Id];
        testAccountWithRelationship = [SELECT Id, Name, LastModifiedDate, (SELECT Name FROM Contacts) FROM Account WHERE ID = :testAccount.Id];
        testContact = [SELECT Id, LastName, Account.Name FROM Contact WHERE ID = :testContact.Id];
    }


    //---- checkWithException ----//


    private static void setupCheckAccessWithException() {
        setup();
        flsCheck = new loli_utils_SFObjectFLSCheck(testAccount);
    }


    private static TestMethod void doesNotThrowWhenUserHasTheRequiredAccessRights() {
        setupCheckAccessWithException();
        flsCheck.checkWithException(loli_utils_Enum.FLSType.access);

        System.assertEquals(testAccountName, testAccount.Name);
    }

    private static TestMethod void doesNotThrowWhenQueryContainsParentFields() {
        setupCheckAccessWithException();
        flsCheck = new loli_utils_SFObjectFLSCheck(testContact);
        flsCheck.checkWithException(loli_utils_Enum.FLSType.access);

        System.assertEquals(testAccountName, testAccount.Name);
        System.assertEquals(testContactName, testContact.LastName);
    }

    private static TestMethod void doesNotThrowWhenQueryContainsRelationshipQuery() {
        setupCheckAccessWithException();
        flsCheck = new loli_utils_SFObjectFLSCheck(testAccountWithRelationship);

        flsCheck.checkWithException(loli_utils_Enum.FLSType.access);

        System.assertEquals(testAccountName, testAccount.Name);
    }

    //---- check ----//

    private static void setupCheck() {
        setup();
        flsCheck = new loli_utils_SFObjectFLSCheck(testAccount);
    }


    private static TestMethod void returnsTrueWhenFlsTypeIsFulfilled() {
        setupCheck();
        Boolean isCheck = flsCheck.check(loli_utils_Enum.FLSType.access);

        System.assert(isCheck != null);
        System.assert(isCheck);
    }

    private static TestMethod void returnsTrueWhenFlsTypeIsFulfilledForParentFields() {
        setupCheck();
        flsCheck = new loli_utils_SFObjectFLSCheck(testContact);
        Boolean isCheck = flsCheck.check(loli_utils_Enum.FLSType.access);

        System.assert(isCheck != null);
        System.assert(isCheck);
    }

    private static TestMethod void returnsTrueWhenFlsTypeIsFulfilledForRelationshipFields() {
        setupCheck();
        flsCheck = new loli_utils_SFObjectFLSCheck(testAccountWithRelationship);
        Boolean isCheck = flsCheck.check(loli_utils_Enum.FLSType.access);

        System.assert(isCheck != null);
        System.assert(isCheck);
    }

    //---- replaceWithNull ----//

    private static void setupReplaceWithNull() {
        setup();
        flsCheck = new loli_utils_SFObjectFLSCheck(testAccount);
    }

    private static TestMethod void doesNotReplaceFieldsWhenFlsTypeIsFulfilled() {
        setupReplaceWithNull();

        flsCheck.replaceWithNull(loli_utils_Enum.FLSType.access);

        System.assertEquals(testAccountName, testAccount.Name);
    }

    private static TestMethod void doesNotReplaceFieldsWhenFlsTypeIsFulfilledForParentFields() {
        setupReplaceWithNull();
        flsCheck = new loli_utils_SFObjectFLSCheck(testContact);

        flsCheck.replaceWithNull(loli_utils_Enum.FLSType.access);

        System.assertEquals(testAccountName, testAccount.Name);
        System.assertEquals(testContactName, testContact.LastName);
    }

    private static TestMethod void doesNotReplaceFieldsWhenFlsTypeIsFulfilledForRelationshipFields() {
        setupReplaceWithNull();
        flsCheck = new loli_utils_SFObjectFLSCheck(testAccountWithRelationship);

        flsCheck.replaceWithNull(loli_utils_Enum.FLSType.access);

        System.assertEquals(testAccountName, testAccount.Name);
    }




}