@isTest(SeeAllData=false)
private class ProgressHistoryControllerTest_InquiryPKG {

    @isTest
    static void getTodaysCallbackListTest() {
        Test.startTest();
        TestUtil_InquiryPKG.createProgressHistoryCallBackList();
        List<ProgressHistory__c> callbackListResults = ProgressHistoryController.getTodaysCallbackList();
        
        System.assert(!callbackListResults.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void getEscalationsTest() {
        Test.startTest();
        TestUtil_InquiryPKG.createProgressHistoryEscalations();
        List<ProgressHistory__c> escalationResults = ProgressHistoryController.getEscalations();
        
        System.assert(!escalationResults.isEmpty());
        Test.stopTest();
    }
}