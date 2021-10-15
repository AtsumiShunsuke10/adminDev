@isTest(SeeAllData=false)
private class InformationControllerTest {

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
        List<Information__c> results = InformationController.getInformationList();
        System.assert(!results.isEmpty());
        Test.stopTest();
    }
}