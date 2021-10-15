@isTest
public class TestUtil_InquiryPKG {
    public static Case createCase() {
        Contact contact = createContact('田中太郎');
        Case newCase = new Case();    
        newCase.Status = '対応中';
        newCase.ContactId = contact.Id;
        insert newCase;
        newCase = [SELECT Id, ContactId FROM Case WHERE ContactId = :newCase.ContactId];

        return newCase;
    }

    public static Case createCase(Id ownerId) {
        Contact contact = createContact('田中太郎');
        Case newCase = new Case();    
        newCase.Status = '対応中';
        newCase.ContactId = contact.Id;
        newCase.OwnerId = ownerId;
        insert newCase;
        newCase = [SELECT Id, ContactId FROM Case WHERE ContactId = :newCase.ContactId];

        return newCase;
    }

    public static Contact createContact(String name) {
        Account account = createAccount('XXXX株式会社');
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Lastname = name;
        insert contact;
        contact = [SELECT Id FROM Contact WHERE Name = :contact.Lastname limit 1];

        return contact;
    }

    public static Account createAccount(String name) {
        Account account = new Account();
        account.Name = name;
        insert account;
        account = [SELECT Id FROM Account WHERE Name = :account.Name limit 1];

        return account;
    }

    public static FAQ__c createFAQ() {
        FAQ__c faq = new FAQ__c();
        faq.Title__c = 'タイトル';
        faq.CategoryL__c = 'カテゴリ大01';
        faq.CategoryM__c = 'カテゴリ中01';
        faq.CategoryS__c = 'カテゴリ小01';
        insert faq;
        faq = [SELECT Id FROM FAQ__c WHERE Title__c = :faq.Title__c limit 1];

        return faq;
    }

    public static FAQHistory__c createFAQHistory() {
        FAQ__c faq = createFAQ();
        FAQHistory__c faqHistory = new FAQHistory__c();
        faqHistory.FAQ__c = faq.Id;
        insert faqHistory;
        faqHistory = [SELECT Id, FAQ__c, Case__c FROM FAQHistory__c WHERE FAQ__c = :faq.Id];

        return faqHistory;
    }

    public static Inquiry__c createInquiry() {
        Inquiry__c newinquiry = new Inquiry__c();
        newinquiry.Status__c = '対応中';
        insert newinquiry;
        newinquiry = [SELECT Id, Status__c FROM Inquiry__c];

        return newinquiry;
    }

    public static void createProgressHistoryCallBackList() {
        Inquiry__c newInquiry = createInquiry();
        ProgressHistory__c ProgressHistoryCallbackList = new ProgressHistory__c();
        ProgressHistoryCallbackList.Inquiry__c = newInquiry.Id;
        ProgressHistoryCallbackList.RecordTypeId = '0120T0000000mUHQAY';
        ProgressHistoryCallbackList.Status__c = '未対応';
        ProgressHistoryCallbackList.CallBackDateAndTime__c = Datetime.now();
        insert ProgressHistoryCallbackList;
    }

    public static void createProgressHistoryEscalations() {
        Inquiry__c newInquiry = createInquiry();
        ProgressHistory__c ProgressHistoryEscalations = new ProgressHistory__c();
        ProgressHistoryEscalations.Inquiry__c = newInquiry.Id;
        ProgressHistoryEscalations.RecordTypeId = '0120T0000000mUCQAY';
        ProgressHistoryEscalations.Status__c = '対応中';
        insert ProgressHistoryEscalations;
    }
}