@isTest(SeeAllData=false)
private class FaqControllerTest_InquiryPKG {

    @TestSetup
    static void init() {
        TestUtil_InquiryPKG.createFAQ();
    }

    @isTest
    static void test01() {
        Test.startTest();

        List<FAQ__c> results = FaqController.getRecommendFaqs('', '', '');

        System.assertEquals(null, results);
        Test.stopTest();
    }

    @isTest
    static void test02() {
        Test.startTest();

        List<FAQ__c> results = FaqController.getRecommendFaqs('カテゴリ大01', 'カテゴリ中01', 'カテゴリ小01');

        System.assert(!results.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void test03() {
        Test.startTest();

        List<FAQ__c> results = FaqController.findFaqs('あいうえお');

        System.assertEquals(null, results);
        Test.stopTest();
    }

    @isTest
    static void test04() {
        Test.startTest();

        String key = 'タイトル';
        FAQ__c faq = [SELECT Id FROM FAQ__c WHERE Title__c = :key limit 1];
        List<Id> searchResultsIds = new List<Id>();
        searchResultsIds.add(faq.Id);
        Test.setFixedSearchResults(searchResultsIds);
        List<FAQ__c> results = FaqController.findFaqs(key);

        System.assert(!results.isEmpty());
        Test.stopTest();
    }
}