@isTest(SeeAllData=false)
public with sharing class EscalationHistoryTriggerHandlerTest {

    @TestSetup
    static void init() {
    }

    @isTest
    static void EscalationHistoryTriggerHandlerTest() {
        Case c = TestUtil.createCase();
        c.Status = 'エスカレーション';
        update c;
        EscalationHistory__c escalation = new EscalationHistory__c();
        escalation.Case__c = c.Id;
        Test.startTest();
        try {
            insert escalation;
        } catch(Exception e) {
            Boolean result = e.getMessage().contains(System.Label.msg001);
            System.assertEquals(true, result);
        }
        Test.stopTest();    
    }
}