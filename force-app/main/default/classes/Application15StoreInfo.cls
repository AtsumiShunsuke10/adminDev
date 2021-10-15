public with sharing class Application15StoreInfo {
    @AuraEnabled(cacheable=true)
    public static List<Store15__c> getStoreRecords(Id app15RecordId) {
        try {
            return [
                SELECT Id, Name, StoreIndex__c, Application_Store_Name__c, Application_Store_Apply_Amount__c,
                        Application_Store_Postal_Code__c, Application_Store_Address__c,
                        Application_Store_Address_Type__c, Application_Store_Start_Date__c,
                        Application_Store_End_Date__c, Application_Store_Days__c,
                        Application_Store_Per_Date__c, Application_Store_Effort_DetailsA__c,
                        Application_Store_Address_Check__c, Store_Appearance_Document__c, Store_Business_Permit_Document__c
                FROM Store15__c
                WHERE Application15__c =: app15RecordId
                ORDER BY StoreIndex__c
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getRecordCount(Id app15RecordId) {
        try {
            return[
                SELECT COUNT()
                FROM Store15__c
                WHERE Application15__c =: app15RecordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}