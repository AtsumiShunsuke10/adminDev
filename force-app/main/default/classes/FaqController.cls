public with sharing class FaqController {
    @AuraEnabled(cacheable=true)
    public static List<FAQ__c> getRecommendFaqs(String category, String subCategory, String subSubCategory) {
        List<FAQ__c> faqs = [
            SELECT Id, Question__c, Answer__c, Title__c, Summary__c 
            FROM FAQ__c 
            WHERE CategoryL__c=:category AND CategoryM__c=:subCategory AND CategoryS__c=:subSubCategory
        ];
        if(faqs.isEmpty()) {
            return null;
        }
        return faqs;
    }

    @AuraEnabled(cacheable=true)
    public static List<FAQ__c> findFaqs(String key) {
        List<List<SObject>> faqs = [ FIND :key IN ALL FIELDS RETURNING FAQ__c(Question__c, Answer__c, Title__c, Summary__c) ];
        if(faqs[0].isEmpty()) {
            return null;
        }
        return (FAQ__c[])faqs[0];
    }
}