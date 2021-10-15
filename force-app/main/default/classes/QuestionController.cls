public without sharing class QuestionController {
    public List<Question__c> QuestionList1 {get; set;}
    public List<Question__c> QuestionList2 {get; set;}
    public List<Question__c> QuestionList3 {get; set;}
    public List<Question__c> QuestionList4 {get; set;}
    public List<Question__c> QuestionList5 {get; set;}

    public QuestionController(){
        System.debug('★★★QuestionController　Start');
        getList();
        System.debug('★★★QuestionController　End');
    }

    public void getList(){
        System.debug('★★★getList　Start');
        QuestionList1 = [SELECT  Id
                                ,Category__c        // カテゴリ
                                ,Title__c           // タイトル
                                ,Text__c            // 本文
                        FROM    Question__c
                        WHERE   Category__c = '対象者'
                        ORDER BY SortOrder__c,LastModifiedDate, Name DESC
                        ];

        QuestionList2 = [SELECT  Id
                                ,Category__c        // カテゴリ
                                ,Title__c           // タイトル
                                ,Text__c            // 本文
                        FROM    Question__c
                        WHERE   Category__c = 'オンライン申請の住所について'
                        ORDER BY SortOrder__c,LastModifiedDate, Name DESC
                        ];

        QuestionList3 = [SELECT  Id
                                ,Category__c        // カテゴリ
                                ,Title__c           // タイトル
                                ,Text__c            // 本文
                        FROM    Question__c
                        WHERE   Category__c = '営業許可書について'
                        ORDER BY SortOrder__c,LastModifiedDate, Name DESC
                        ];

        QuestionList4 = [SELECT  Id
                                ,Category__c        // カテゴリ
                                ,Title__c           // タイトル
                                ,Text__c            // 本文
                        FROM    Question__c
                        WHERE   Category__c = '申請手続き'
                        ORDER BY SortOrder__c,LastModifiedDate, Name DESC
                        ];

        QuestionList5 = [SELECT  Id
                                ,Category__c        // カテゴリ
                                ,Title__c           // タイトル
                                ,Text__c            // 本文
                        FROM    Question__c
                        WHERE   Category__c = '支給額の算定'
                        ORDER BY SortOrder__c,LastModifiedDate, Name DESC
                        ];

        System.debug('★★★getList　End');
    }
}