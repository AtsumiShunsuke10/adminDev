/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第15弾）共通処理
 *  クラス名       : Application15Utility
 *  概要           : 申請（感染症拡大防止協力金：第15弾）共通処理
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
public without sharing class Application15Utility {

    /**
     * すべての項目を含めるクエリを作成
     *
     * ## tableName (String): オブジェクト名
     * ## whereCondition (String): WHEREオプション
     * ## orderStr (String): ORDER_BYオプション
     * ## limitStr (String): LIMITオプション
     * @@ Return String: クエリ文字列
     */
    public static String getAllColumnSoql(String tableName, String whereCondition, String orderStr, String LimitStr) {
        List<String> fieldsList = getAllColumnsList(tableName);
        // レコードタイプを追加
        fieldsList.add('RecordType.Name');
        String query = makeSoql(fieldsList, tableName, whereCondition, orderStr, LimitStr, '');
        
        return query;
    }

    /**
     * IDによるすべての項目を含めるクエリを作成()
     *
     * ## tableName (String): オブジェクト名
     * ## recordId (String): クエリするId
     * @@ Return String: クエリ文字列
     */
    public static String getAllColumnSoql(String tableName, String recordId) {
        List<String> fieldsList = getAllColumnsList(tableName);
        // レコードタイプを追加
        fieldsList.add('RecordType.Name');
        String query = makeSoql(fieldsList, tableName, 'id = \''+ recordId +'\'', '', '', '');
        
        return query;
    }

    /**
     * 該当オブジェクトのすべて項目名を文字列で取得
     *
     * ## tableName (String): オブジェクト名
     * @@ Return String: ブジェクトのすべて項目名の文字列
     */
    public static List<String> getAllColumnsList(String tableName) {
        Map<String, Schema.SObjectField> fieldsMap = getFieldsMap(tableName);
        List<String> fields = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            fields.add(fieldName);
        }
        return fields;
    }

    /**
     * 該当オブジェクトをマップする
     *
     * ## tableName (String): オブジェクト名
     * @@ Return Map<String,Schema.SObjectField>: オブジェクトの項目マップ
     */
    private static Map<String, Schema.SObjectField> getFieldsMap(String tableName) {
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get(tableName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        return r.fields.getMap();
    }
    
    /**
     * クエリを作成
     *
     * ## fileds (List<String>): 項目名のリスト
     * ## objectName (String): オブジェクト名
     * ## whereCondition (String): WHEREオプション
     * ## orderStr (String): ORDER_BYオプション
     * ## limitStr (String): LIMITオプション
     * ## childSoql (String): 子オブジェクトセレクト文字列
     * @@ Return String: クエリ文字列
     */
    public static String makeSoql(List<String> fileds,String objectName, String whereCondition,String orderStr,String limitStr,String childSoql){
        String soql='SELECT ';
        if(!fileds.isEmpty()){
            soql += String.join(fileds,',');
        }
        if(!String.isEmpty(childSoql)){
            soql += ' ( ';
            soql += childSoql;
            soql += ' ) ';
        }
        if(!String.isEmpty(objectName)){
            soql += ' FROM ';
            soql += objectName;
        }
        if(!String.isEmpty(whereCondition)){
            soql += ' WHERE ';
            soql +=  whereCondition;
        }
        if(!String.isEmpty(orderStr)){
            soql += ' ORDER BY ';
            soql += orderStr;
        }
        if(!String.isEmpty(limitStr)){
            soql += ' LIMIT ';
            soql += limitStr;
        }
        return soql;
    }
    
    /**
     * 添付したファイルを取得
     *
     * ## parentId (String): 親レコードのID
     * @@ Return List<ContentVersion>: 添付ファイルのリスト
     */
    public static List<ContentVersion> initIssAttachment(String parentId) {
        // idチェック
        if ( parentId != null && parentId.trim() != '' ) {
            if ( [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId =: parentId] > 0 ) {
                List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId];
                List<String> cdlIdList = new List<String>();
                for(ContentDocumentLink cdl : cdlList){
                    cdlIdList.add(cdl.ContentDocumentId);
                }
                
                return [select Id,title,Description,FileExtension,ReasonForChange,ContentBodyId,ContentDocumentId from ContentVersion where ContentDocumentId = :cdlIdList ORDER BY title,CreatedDate DESC];
            }
        }
        // no row selected create new empty list
        return new List<ContentVersion>();
    }

    /**
     * 全角→半角変換
     *
     * @param value 変換元文字列
     * @return 半角文字列
     */
    public static String convertFullToHalf(String value) {
        String result;
        // 変換内容がない場合
        if(String.isEmpty(value)) {
            result = '';
        }else{
            // 半角文字のみなら以降スキップ
            if (Pattern.matches('[ -~]+', value)) {
                result = value;
            }else{
                // 濁音、半濁音は2文字で1文字に変換されるため先に実施
                Map<String, String> fulltoHalfMap1 = new Map<String, String>();
                fulltoHalfMap1.put('ガ' , 'ｶﾞ');
                fulltoHalfMap1.put('ギ' , 'ｷﾞ');
                fulltoHalfMap1.put('グ' , 'ｸﾞ');
                fulltoHalfMap1.put('ゲ' , 'ｹﾞ');
                fulltoHalfMap1.put('ゴ' , 'ｺﾞ');
                fulltoHalfMap1.put('ザ' , 'ｻﾞ');
                fulltoHalfMap1.put('ジ' , 'ｼﾞ');
                fulltoHalfMap1.put('ズ' , 'ｽﾞ');
                fulltoHalfMap1.put('ゼ' , 'ｾﾞ');
                fulltoHalfMap1.put('ゾ' , 'ｿﾞ');
                fulltoHalfMap1.put('ダ' , 'ﾀﾞ');
                fulltoHalfMap1.put('ヂ' , 'ﾁﾞ');
                fulltoHalfMap1.put('ヅ' , 'ﾂﾞ');
                fulltoHalfMap1.put('デ' , 'ﾃﾞ');
                fulltoHalfMap1.put('ド' , 'ﾄﾞ');
                fulltoHalfMap1.put('バ' , 'ﾊﾞ');
                fulltoHalfMap1.put('ビ' , 'ﾋﾞ');
                fulltoHalfMap1.put('ブ' , 'ﾌﾞ');
                fulltoHalfMap1.put('ベ' , 'ﾍﾞ');
                fulltoHalfMap1.put('ボ' , 'ﾎﾞ');
                fulltoHalfMap1.put('パ' , 'ﾊﾟ');
                fulltoHalfMap1.put('ピ' , 'ﾋﾟ');
                fulltoHalfMap1.put('プ' , 'ﾌﾟ');
                fulltoHalfMap1.put('ペ' , 'ﾍﾟ');
                fulltoHalfMap1.put('ポ' , 'ﾎﾟ');
                fulltoHalfMap1.put('ヴ' , 'ｳﾞ');

                Map<String, String> fulltoHalfMap2 = new Map<String, String>();
                fulltoHalfMap2.put( '！',  '!' );
                fulltoHalfMap2.put( '”',  '"' );
                fulltoHalfMap2.put( '＃',  '#' );
                fulltoHalfMap2.put( '＄',  '$' );
                fulltoHalfMap2.put( '％',  '%' );
                fulltoHalfMap2.put( '＆',  '&' );
                fulltoHalfMap2.put(  '’',  '\'');
                fulltoHalfMap2.put( '（',  '(' );
                fulltoHalfMap2.put( '）',  ')' );
                fulltoHalfMap2.put( '＊',  '*' );
                fulltoHalfMap2.put( '＋',  '+' );
                fulltoHalfMap2.put( '，',   '' );
                fulltoHalfMap2.put( '−',  '-' );
                fulltoHalfMap2.put( '．',  '.' );
                fulltoHalfMap2.put( '／',  '/' );
                fulltoHalfMap2.put( '０',  '0' );
                fulltoHalfMap2.put( '１',  '1' );
                fulltoHalfMap2.put( '２',  '2' );
                fulltoHalfMap2.put( '３',  '3' );
                fulltoHalfMap2.put( '４',  '4' );
                fulltoHalfMap2.put( '５',  '5' );
                fulltoHalfMap2.put( '６',  '6' );
                fulltoHalfMap2.put( '７',  '7' );
                fulltoHalfMap2.put( '８',  '8' );
                fulltoHalfMap2.put( '９',  '9' );
                fulltoHalfMap2.put( '：',  ':' );
                fulltoHalfMap2.put( '；',  ';' );
                fulltoHalfMap2.put( '＜',  '<' );
                fulltoHalfMap2.put( '＝',  '=' );
                fulltoHalfMap2.put( '＞',  '>' );
                fulltoHalfMap2.put( '？',  '?' );
                fulltoHalfMap2.put( '＠',  '@' );
                fulltoHalfMap2.put( 'Ａ',  'A' );
                fulltoHalfMap2.put( 'Ｂ',  'B' );
                fulltoHalfMap2.put( 'Ｃ',  'C' );
                fulltoHalfMap2.put( 'Ｄ',  'D' );
                fulltoHalfMap2.put( 'Ｅ',  'E' );
                fulltoHalfMap2.put( 'Ｆ',  'F' );
                fulltoHalfMap2.put( 'Ｇ',  'G' );
                fulltoHalfMap2.put( 'Ｈ',  'H' );
                fulltoHalfMap2.put( 'Ｉ',  'I' );
                fulltoHalfMap2.put( 'Ｊ',  'J' );
                fulltoHalfMap2.put( 'Ｋ',  'K' );
                fulltoHalfMap2.put( 'Ｌ',  'L' );
                fulltoHalfMap2.put( 'Ｍ',  'M' );
                fulltoHalfMap2.put( 'Ｎ',  'N' );
                fulltoHalfMap2.put( 'Ｏ',  'O' );
                fulltoHalfMap2.put( 'Ｐ',  'P' );
                fulltoHalfMap2.put( 'Ｑ',  'Q' );
                fulltoHalfMap2.put( 'Ｒ',  'R' );
                fulltoHalfMap2.put( 'Ｓ',  'S' );
                fulltoHalfMap2.put( 'Ｔ',  'T' );
                fulltoHalfMap2.put( 'Ｕ',  'U' );
                fulltoHalfMap2.put( 'Ｖ',  'V' );
                fulltoHalfMap2.put( 'Ｗ',  'W' );
                fulltoHalfMap2.put( 'Ｘ',  'X' );
                fulltoHalfMap2.put( 'Ｙ',  'Y' );
                fulltoHalfMap2.put( 'Ｚ',  'Z' );
                fulltoHalfMap2.put( '［',  '[' );
                fulltoHalfMap2.put(  '￥',  '\\');
                fulltoHalfMap2.put( '］',  ']' );
                fulltoHalfMap2.put( '＾',  '^' );
                fulltoHalfMap2.put( '＿',  '_' );
                fulltoHalfMap2.put( '‘',  '`' );
                fulltoHalfMap2.put( 'ａ',  'a' );
                fulltoHalfMap2.put( 'ｂ',  'b' );
                fulltoHalfMap2.put( 'ｃ',  'c' );
                fulltoHalfMap2.put( 'ｄ',  'd' );
                fulltoHalfMap2.put( 'ｅ',  'e' );
                fulltoHalfMap2.put( 'ｆ',  'f' );
                fulltoHalfMap2.put( 'ｇ',  'g' );
                fulltoHalfMap2.put( 'ｈ',  'h' );
                fulltoHalfMap2.put( 'ｉ',  'i' );
                fulltoHalfMap2.put( 'ｊ',  'j' );
                fulltoHalfMap2.put( 'ｋ',  'k' );
                fulltoHalfMap2.put( 'ｌ',  'l' );
                fulltoHalfMap2.put( 'ｍ',  'm' );
                fulltoHalfMap2.put( 'ｎ',  'n' );
                fulltoHalfMap2.put( 'ｏ',  'o' );
                fulltoHalfMap2.put( 'ｐ',  'p' );
                fulltoHalfMap2.put( 'ｑ',  'q' );
                fulltoHalfMap2.put( 'ｒ',  'r' );
                fulltoHalfMap2.put( 'ｓ',  's' );
                fulltoHalfMap2.put( 'ｔ',  't' );
                fulltoHalfMap2.put( 'ｕ',  'u' );
                fulltoHalfMap2.put( 'ｖ',  'v' );
                fulltoHalfMap2.put( 'ｗ',  'w' );
                fulltoHalfMap2.put( 'ｘ',  'x' );
                fulltoHalfMap2.put( 'ｙ',  'y' );
                fulltoHalfMap2.put( 'ｚ',  'z' );
                fulltoHalfMap2.put( '｛',  '{' );
                fulltoHalfMap2.put( '｜',  '|' );
                fulltoHalfMap2.put( '｝',  '}' );
                fulltoHalfMap2.put( '〜',  '~' );
                fulltoHalfMap2.put( '　',  ' ' );
                fulltoHalfMap2.put( '。',  '｡' );
                fulltoHalfMap2.put( '「',  '｢' );
                fulltoHalfMap2.put( '」',  '｣' );
                fulltoHalfMap2.put( '、',  '､' );
                fulltoHalfMap2.put( '・',  '･' );
                fulltoHalfMap2.put( 'ヲ',  'ｦ' );
                fulltoHalfMap2.put( 'ァ',  'ｧ' );
                fulltoHalfMap2.put( 'ィ',  'ｨ' );
                fulltoHalfMap2.put( 'ゥ',  'ｩ' );
                fulltoHalfMap2.put( 'ェ',  'ｪ' );
                fulltoHalfMap2.put( 'ォ',  'ｫ' );
                fulltoHalfMap2.put( 'ャ',  'ｬ' );
                fulltoHalfMap2.put( 'ュ',  'ｭ' );
                fulltoHalfMap2.put( 'ョ',  'ｮ' );
                fulltoHalfMap2.put( 'ッ',  'ｯ' );
                fulltoHalfMap2.put( 'ー',  'ｰ' );
                fulltoHalfMap2.put( 'ア',  'ｱ' );
                fulltoHalfMap2.put( 'イ',  'ｲ' );
                fulltoHalfMap2.put( 'ウ',  'ｳ' );
                fulltoHalfMap2.put( 'エ',  'ｴ' );
                fulltoHalfMap2.put( 'オ',  'ｵ' );
                fulltoHalfMap2.put( 'カ',  'ｶ' );
                fulltoHalfMap2.put( 'キ',  'ｷ' );
                fulltoHalfMap2.put( 'ク',  'ｸ' );
                fulltoHalfMap2.put( 'ケ',  'ｹ' );
                fulltoHalfMap2.put( 'コ',  'ｺ' );
                fulltoHalfMap2.put( 'サ',  'ｻ' );
                fulltoHalfMap2.put( 'シ',  'ｼ' );
                fulltoHalfMap2.put( 'ス',  'ｽ' );
                fulltoHalfMap2.put( 'セ',  'ｾ' );
                fulltoHalfMap2.put( 'ソ',  'ｿ' );
                fulltoHalfMap2.put( 'タ',  'ﾀ' );
                fulltoHalfMap2.put( 'チ',  'ﾁ' );
                fulltoHalfMap2.put( 'ツ',  'ﾂ' );
                fulltoHalfMap2.put( 'テ',  'ﾃ' );
                fulltoHalfMap2.put( 'ト',  'ﾄ' );
                fulltoHalfMap2.put( 'ナ',  'ﾅ' );
                fulltoHalfMap2.put( 'ニ',  'ﾆ' );
                fulltoHalfMap2.put( 'ヌ',  'ﾇ' );
                fulltoHalfMap2.put( 'ネ',  'ﾈ' );
                fulltoHalfMap2.put( 'ノ',  'ﾉ' );
                fulltoHalfMap2.put( 'ハ',  'ﾊ' );
                fulltoHalfMap2.put( 'ヒ',  'ﾋ' );
                fulltoHalfMap2.put( 'フ',  'ﾌ' );
                fulltoHalfMap2.put( 'ヘ',  'ﾍ' );
                fulltoHalfMap2.put( 'ホ',  'ﾎ' );
                fulltoHalfMap2.put( 'マ',  'ﾏ' );
                fulltoHalfMap2.put( 'ミ',  'ﾐ' );
                fulltoHalfMap2.put( 'ム',  'ﾑ' );
                fulltoHalfMap2.put( 'メ',  'ﾒ' );
                fulltoHalfMap2.put( 'モ',  'ﾓ' );
                fulltoHalfMap2.put( 'ヤ',  'ﾔ' );
                fulltoHalfMap2.put( 'ユ',  'ﾕ' );
                fulltoHalfMap2.put( 'ヨ',  'ﾖ' );
                fulltoHalfMap2.put( 'ラ',  'ﾗ' );
                fulltoHalfMap2.put( 'リ',  'ﾘ' );
                fulltoHalfMap2.put( 'ル',  'ﾙ' );
                fulltoHalfMap2.put( 'レ',  'ﾚ' );
                fulltoHalfMap2.put( 'ロ',  'ﾛ' );
                fulltoHalfMap2.put( 'ワ',  'ﾜ' );
                fulltoHalfMap2.put( 'ン',  'ﾝ' );
                fulltoHalfMap2.put( '゛',  'ﾞ' );
                fulltoHalfMap2.put( '゜',  'ﾟ' );
                fulltoHalfMap2.put( '‐',  '-' );
                
                // エスケープ必要文字
                Set<String> escapeChars = new Set<String>();
                escapeChars.add('\\');
                escapeChars.add('*');
                escapeChars.add('+');
                escapeChars.add('.');
                escapeChars.add('?');
                escapeChars.add('{');
                escapeChars.add('}');
                escapeChars.add('(');
                escapeChars.add(')');
                escapeChars.add('[');
                escapeChars.add(']');
                escapeChars.add('^');
                escapeChars.add('$');
                escapeChars.add('|');
                escapeChars.add('/');

                for (String key : fulltoHalfMap1.keySet()) {
                    if (value.contains(key)) {
                        value = value.replaceAll(key, fulltoHalfMap1.get(key));
                    }
                }

                for (String key : fulltoHalfMap2.keySet()) {
                    if (value.contains(key)) {
                        String tempKey = key;
                        if (escapeChars.contains(tempKey)) {
                            tempKey = '\\' + tempKey;
                        }
                        value = value.replaceAll(tempKey, fulltoHalfMap2.get(key));
                    }
                }
                String comma = '，';
                if(value.contains(comma)){
                    value = value.replaceAll(comma, '');
                }
                result = value;
            }
        }
        return result;
    }


    /**
     * 郵便番号で住所マスタから住所を取得
     *
     * @param String postcode 郵便番号
     * @return String 住所
     */
    public static String getAddressByPostCode(String postcode) {

        String address = '';
        List<AddressMaster__c> addMstList = [SELECT
                                                 Prefectures__c,                 // 都道府県
                                                 City__c,                        // 市区郡
                                                 CommonName__c,                  // 大字通称
                                                 District__c                     // 字・丁目
                                             FROM
                                                 AddressMaster__c                // 住所マスタ
                                             WHERE
                                                 PostalCode__c = :postcode       // 郵便番号 = パラメータの郵便番号
                                                 And AbolitionDate__c = '0000'   // 廃棄年月 = '0000' 
                                             ORDER BY City__c,                   // ソート順：市区郡　昇順
                                                      CommonName__c,             // ソート順：大字通称　昇順
                                                      District__c];              // ソート順：字・丁目　昇順
        // 取得した住所が1件の場合、フル住所
        if (addMstList.size() == 1) {

            address += addMstList[0].Prefectures__c + 
                       nullToString(addMstList[0].City__c) +
                       nullToString(addMstList[0].CommonName__c) +
                       nullToString(addMstList[0].District__c);
        
        // 取得した住所が複数件の場合、共通住所
        } else if (addMstList.size() > 1) {
            Set<String> prefectureSet = new Set<String>();
            Set<String> citySet = new Set<String>();
            Set<String> commonNameSet = new Set<String>();
            Set<String> districtSet = new Set<String>();
            for (AddressMaster__c addMst : addMstList) {
                if (String.isNotBlank(addMst.Prefectures__c)) prefectureSet.add(addMst.Prefectures__c);
                if (String.isNotBlank(addMst.City__c)) citySet.add(addMst.City__c);
                if (String.isNotBlank(addMst.CommonName__c)) commonNameSet.add(addMst.CommonName__c);
                if (String.isNotBlank(addMst.District__c)) districtSet.add(addMst.District__c);
            }

            if (prefectureSet.size() == 1) {
                address += new List<String>(prefectureSet)[0];
                if (citySet.size() == 1) {
                    address += new List<String>(citySet)[0];
                    if (commonNameSet.size() == 1) {
                        address += new List<String>(commonNameSet)[0];
                        if (districtSet.size() == 1) {
                            address += new List<String>(districtSet)[0];
                        }
                    }
                }
            }
        }

        return address;
    }

    /**
     * 文字列がnullの場合、空文字列へ変換する
     * 
     * @param String value 文字列
     * @return String 変換された文字列
     */
    public static String nullToString(String value) {
        
        return value == null? '' : value;

    }
   
    /**
     * 和暦年号変更年のマップを取得
     * 
     * @return Map<Integer, Date> 西暦年-年号変更日付のマップ
     */
    public static Map<Integer, Date> createWarekiChangeYear() {
        Map<Integer, Date> changeMap = new Map<Integer, Date>();
        changeMap.put(1912, Date.newInstance(1912, 7, 29));
        changeMap.put(1926, Date.newInstance(1926, 12, 24));
        changeMap.put(1989, Date.newInstance(1989, 1, 7));
        changeMap.put(2019, Date.newInstance(2019, 4, 30));

        return changeMap;
    }

    /**
     * 和暦年分のValueリスト、Labelリストを取得
     * 
     * @param String valueList Valueリスト
     * @param String labelList Labelリスト
     */
    public static void createWarekiYear(List<Integer> valueList, List<String> labelList) {
        
        if (valueList == null) valueList = new List<Integer>();
        if (labelList == null) labelList = new List<String>();
        
        Integer apartYears = Date.today().year() - 2018;
        for (Integer i = apartYears; i >= 2; i--) {
            valueList.add(2018 + i);
            labelList.add('令和' + i);
        }
        valueList.add(2019);
        labelList.add('令和元');
        
        for (Integer i = 31; i >= 2; i--) {
            valueList.add(1988 + i);
            labelList.add('平成' + i);
        }
        valueList.add(1989);
        labelList.add('平成元');

        for (Integer i = 64; i >= 2; i--) {
            valueList.add(1925 + i);
            labelList.add('昭和' + i);
        }
        valueList.add(1926);
        labelList.add('昭和元');

    }

    /**
     * 和暦日付への変換
     * 
     * @param String dateStr YYYY-MM-DD形の日付
     * @param String type 0:和暦年月日 1:和暦年月 2:和暦年
     * 
     * @return String 和暦日付
     */
    public static String changeWarekiYear(String dateStr,Integer type) {
        List<String> parts = dateStr.split('-');
        //和暦　年
        String warekiYear;
        //和暦　月
        String warekiMonth=parts[1]+'月';
        //和暦　日
        String warekiDate=parts[2]+'日';
        
        Integer apartYears = Integer.valueOf(parts[0]) - 2018;
        if(apartYears==0){
            warekiYear = '令和元年';
        }else if(apartYears>0){
            warekiYear = '令和'+apartYears+'年';
        }
        
        if(type==1){
            return warekiYear+warekiMonth;
        }
        if(type==2){
            return warekiYear;
        }
        return warekiYear+warekiMonth+warekiDate;
    }
    
    /**
     * 「営業時間等短縮実施期間」選択オプションを作成
     *
     * @return List<SelectOption> 「営業時間等短縮実施期間」選択オプションのリスト
     */
    public static List<SelectOption> getSelectTsbDate(Date startDate, Date endDate){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));

        Integer dueDays = startDate.daysBetween(endDate);
        for (Integer i = 0; i <= dueDays; i++) {
            Date d = startDate.addDays(i);
            Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
            options.add(new SelectOption(String.valueOf(d), dt.format('M月d日')));
        }
        
        return options;
    }
    
    /**
     * 指定フォーマットで日付をフォーマットする
     * 
     * @param Date dt 日付
     * @param String formatStr 指定フォーマット
     * @return String フォーマット日付文字列
     */
    public static String fmtDate(Date dt, String formatStr) {
        
        String fmtDt = '';
        if (dt != null && String.isNotBlank(formatStr)) {
            fmtDt = Datetime.newInstance(dt.year(), dt.month(), dt.day()).format(formatStr);
        } 
        return fmtDt;

    }
    
    /**
     * 申請（第2弾）のレコードを取得する
     * 
     * @param Id app2Id 申請（第2弾）のレコードId
     * @return Application2__c 申請（第2弾）のレコード
     */
    public static Application2__c getApplication2Info(Id app2Id) {
        
        Application2__c app2 = null;
        List<Application2__c> app2List = [SELECT Applicant_Division__c
                                                , Applicant_Business_Name__c
                                                , Applicant_Postal_Code__c
                                                , Applicant_Address__c
                                                , Applicant_Title__c
                                                , Applicant_Name__c
                                                , Applicant_Phone__c
                                                , Corporate_Number__c
                                                // , Industry__c
                                                // , Other_Industry__c
                                                , Financial_Institution_Lookup__r.Name
                                                , Financial_Institution_Lookup__c
                                                , Finacial_Account_Type__c
                                                , Finacial_Branch_Name__c
                                                , Finacial_Branch_Code__c
                                                , Account_Holder__c
                                                , Finacial_Account_Number__c
                                                //, Monthly_Average_Sales__c
                                            FROM Application2__c
                                            WHERE id= :app2Id];
        if (app2List.size() > 0)  app2 = app2List[0];

        return app2;
    }

    /**
     * 申請（第1弾）のレコードを取得する
     * 
     * @param Id appId 申請（第1弾）のレコードId
     * @return Application__c 申請（第1弾）のレコード
     */
    public static Application__c getApplicationInfo(Id appId) {
        
        Application__c app = null;
        List<Application__c> appList = [SELECT Applicant_Division__c
                                                , Applicant_Business_Name__c
                                                , Applicant_Postal_Code__c
                                                , Applicant_Address__c
                                                , Applicant_Title__c
                                                , Applicant_Name__c
                                                , Applicant_Phone__c
                                                , Corporate_Number__c
                                                //, Industry__c
                                                //, Other_Industry__c
                                                , Financial_Institution_Lookup__r.Name
                                                , Financial_Institution_Lookup__c
                                                , Finacial_Account_Type__c
                                                , Finacial_Branch_Name__c
                                                , Finacial_Branch_Code__c
                                                , Account_Holder__c
                                                , Finacial_Account_Number__c
                                            FROM Application__c
                                            WHERE id= :appId];
        if (appList.size() > 0)  app = appList[0];

        return app;
    }

    /**
     * リスト分割
     * 
     * @param List<SObject> list データリスト
     * @param Integer pageIdx 指定ページ
     * @return List<SObject> 分割部分
     */
    public static List<SObject> getPageRecordList(List<SObject> sList,Integer pageIdx) {
        Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
        
        if(sList==null||pageIdx < 1){
            return null;
        }
        
        Integer sIdx= (pageIdx-1)*maxNum;
        Integer eIdx= pageIdx*maxNum;
        
        if(sList.size() < eIdx){
            eIdx = sList.size();
        }

        List<SObject> rList = new List<SObject>();
        for(Integer i= sIdx;i<eIdx;i++){
            rList.add(sList[i]);
        }
        return rList;
    }
}