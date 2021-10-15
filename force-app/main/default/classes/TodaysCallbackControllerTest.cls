@isTest(SeeAllData=false)
private class TodaysCallbackControllerTest {

    @TestSetup
    static void init() {
    }

    @isTest
    static void getTodaysCallbackListTest01() {
        Test.startTest();

        TestUtil.createCallbackHistory();
        List<CallbackHistory__c> results = TodaysCallbackController.getTodaysCallbackList();
        
        System.assert(!results.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void getTodaysCallbackListTest02() {
        Test.startTest();

        List<CallbackHistory__c> results = TodaysCallbackController.getTodaysCallbackList();
        
        System.assertEquals(null, results);
        Test.stopTest();
    }
}