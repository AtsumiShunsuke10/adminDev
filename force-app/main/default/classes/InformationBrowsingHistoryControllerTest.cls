@isTest(SeeAllData=false)
private class InformationBrowsingHistoryControllerTest {

    @TestSetup
    static void init() {
        Information__c information = new Information__c();
        information.Title__c = 'タイトル';
        information.NoticePeriodStart__c = Date.today();
        information.NoticePeriodEnd__c = null;
        information.CCHub__c = 'すべて';
        insert information;
    }

    @isTest
    static void getInformationListTest() {
        Test.startTest();
        Information__c information = [SELECT Id FROM Information__c WHERE Title__c = 'タイトル'];
        List<Object> results = InformationBrowsingHistoryController.getInformationBrowsingHistories(information.Id);
        System.assert(!results.isEmpty());
        Test.stopTest();
    }
}