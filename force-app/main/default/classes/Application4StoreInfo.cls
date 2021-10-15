public with sharing class Application4StoreInfo {
    @AuraEnabled(cacheable=true)
    public static List<Store__c> getStoreRecords(Id app4RecordId) {
        try {
            return [
                SELECT Id, Name, StoreIndex__c, Application_Store_Name__c, Application_Store_Apply_Amount__c,
                        Application_Store_Postal_Code__c, Application_Store_Address__c,
                        Application_Store_Address_Type__c, Application_Store_Start_Date__c,
                        Application_Store_End_Date__c, Application_Store_Days__c,
                        Application_Store_Per_Date__c, Application_Store_Effort_DetailsA__c,
                        Application_Store_Address_Check__c, Store_Appearance_Document__c, Store_Business_Permit_Document__c
                FROM Store__c
                WHERE Application4__c =: app4RecordId
                ORDER BY StoreIndex__c
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getRecordCount(Id app4RecordId) {
        try {
            return[
                SELECT COUNT()
                FROM Store__c
                WHERE Application4__c =: app4RecordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}