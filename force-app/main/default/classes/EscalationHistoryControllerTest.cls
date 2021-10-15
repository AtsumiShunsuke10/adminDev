@isTest(SeeAllData=false)
public with sharing class EscalationHistoryControllerTest {
    @TestSetup
    static void init() {
        Case c = TestUtil.createCase();
        EscalationHistory__c e = new EscalationHistory__c();
        e.Case__c = c.Id;
        insert e;
    }
    @isTest
    static void EscalationHistoryControllerTest() {
        Test.startTest();
        List<EscalationHistory__c> results = EscalationHistoryController.getEscalations();
        System.assert(!results.isEmpty());
        Test.stopTest();
    }
}