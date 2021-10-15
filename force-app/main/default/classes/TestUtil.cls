@isTest
public class TestUtil {
    public static User createUser(String userName, String profileName) {
        Profile profile = getProfile(profileName);
        String profileId = profile.id;

        User user = new User();
        user.Email = userName + '@xxx.com';
        user.UserName = userName + '@trans-cosmos.co.jp';
        user.FirstName = userName;
        user.LastName = 'user';
        user.Alias = 'user';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.localeSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.IsActive = true;
        insert user;
        user = [SELECT Id, IsActive FROM User WHERE UserName = :user.Username];

        return user;
    }

    public static Profile getProfile(String name) {
        List<Profile> profiles = new List<Profile>();
        profiles = [SELECT Id FROM Profile WHERE Name = :name];

        return profiles[0];
    }

    public static Case createCase() {
        Contact contact = createContact('田中太郎');
        Case c = new Case();
        c.Status = '対応中';
        c.ContactId = contact.Id;
        insert c;
        c = [SELECT Id, ContactId FROM Case WHERE ContactId = :c.ContactId];

        return c;
    }

    public static Case createCase(Id ownerId) {
        Contact contact = createContact('田中太郎');
        Case c = new Case();
        c.Status = '対応中';
        c.ContactId = contact.Id;
        c.OwnerId = ownerId;
        insert c;
        c = [SELECT Id, ContactId FROM Case WHERE ContactId = :c.ContactId];

        return c;
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

    public static void createCallbackHistory() {
        Case c = createCase();
        CallbackHistory__c callbackHistory = new CallbackHistory__c();
        callbackHistory.Case__c = c.Id;
        callbackHistory.CallbackDatetime__c = Date.today();
        callbackHistory.IsComplited__c = false;
        insert callbackHistory;
    }

    public static List<Schema.PicklistEntry> getPicklistEntry(String objName, String developerName) {
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(developerName).getDescribe().getPicklistValues();
    }
}