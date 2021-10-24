public with sharing class Application15StoreInfo {
    @testVisible private static Boolean isMathException;

    @AuraEnabled(cacheable=true)
    public static List<Store15__c> getStoreRecords(Id app15RecordId) {
        try {
            if(Test.isRunningTest() && isMathException != null && isMathException == True) {
                Integer num = 10 / 0;
            }
            return [
                SELECT Id, Name, StoreIndex__c, Application_Store_Name__c, Application_Store_Apply_Amount__c,
                        Application_Store_Postal_Code__c, Application_Store_Address__c,
                        Application_Store_Address_Type__c, Application_Store_Start_Date__c,
                        Application_Store_End_Date__c, Application_Store_Days__c,
                        Application_Store_Per_Date__c, Application_Store_Effort_DetailsA__c,
                        Application_Store_Address_Check__c, Store_Business_Permit_Document__c,
                        Store_Appearance_Document__c, Store_Time_Saving_Document_Old__c,
                        FinishedPrice_Paper__c, FinalincomeTaxReturnDocument__c,
                        AmountOfSoldDocument__c, CertificateOfInfectionPrevention__c,
                        Stacker__c, WrittenOath__c, MeterinspectionOrReceipt__c,
                        OLCorrespondingApplicant__c, OLCorrespondingBranchnameAndLocation__c,
                        Store_Business_Permit_Info_Is_Correct__c, BusinessContents_NoOmission__c
                FROM Store15__c
                WHERE Application15__c =: app15RecordId
                ORDER BY StoreIndex__c
            ];
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            if(e.getTypeName() == 'System.MathException') {
                ahe.setMessage('テスト用エラー');
            }
            throw ahe;
        }
    }
}