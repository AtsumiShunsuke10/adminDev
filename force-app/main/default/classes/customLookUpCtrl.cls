/*******************************************************************************
 *  概要: ルックアープの検索用クラス
 *  作成者: 
 *  作成日: 
 *  変更履歴: 
 ******************************************************************************/
public with sharing class customLookUpCtrl {
     /**
     * 検索条件により、内容を検索するメソッド
     *
     * @param searchKeyWord 検索キーワード
     * @param ObjectName 検索オブジェクト名
     * @param filedName 検索条件の項目API名
     * @param relatedFiledname 検索条件の参照関係の項目API名
     * @param relatedFiledId 検索条件の参照関係の項目ID
     * @param addWhereCondtions 検索条件の固定部分
     * @param orderByName 検索条件のソート順番
     * @param limitStr 検索条件の件数
     * @param splitSearchKeyWord 検索キーワードの区別
     * @param andOrStr 検索条件のAND ,OR
     * @param showFieldName 検索結果の表示項目
     * @return 検索結果リスト
     */
    @AuraEnabled
    public static List <wrapObject> fetchLookUpValues(
        String searchKeyWord, String ObjectName,
        String filedName,String relatedFiledname,
        String relatedFiledId,String addWhereCondtions,
        String orderByName,String limitStr,
        String splitSearchKeyWord,String andOrStr,String showFieldName
    )
    {
        //検索条件により、SOQLを生成する
        String sQuery = searchSoql(searchKeyWord, ObjectName,filedName,relatedFiledname,relatedFiledId,addWhereCondtions,orderByName,limitStr,splitSearchKeyWord,andOrStr,showFieldName);
        system.debug('sQuery:'+sQuery);
        //結果を返す　リスト変数
        List <wrapObject> returnList = new List <wrapObject> ();
        //検索内容を格納　リスト変数
        List <sObject> lstOfRecords = new List <sObject>();   
        try{
            lstOfRecords = Database.query(sQuery);
        }catch(Exception e){
            throw new AuraHandledException('設定内容を確認してください。');
        }
       //検索した内容を内部クラスに格納する
        for (sObject obj: lstOfRecords) {
            if(obj!=null){
                returnList.add(new wrapObject(obj,showFieldName));
            }
        }
        return returnList;
    }
    
      /**
     * 検索条件により、SOQL文を作成するメソッド
     *
     * @param searchKeyWord 検索キーワード
     * @param ObjectName 検索オブジェクト名
     * @param filedName 検索条件の項目API名
     * @param relatedFiledname 検索条件の参照関係の項目API名
     * @param relatedFiledId 検索条件の参照関係の項目ID
     * @param addWhereCondtions 検索条件の固定部分
     * @param orderByName 検索条件のソート順番
     * @param limitStr 検索条件の件数
     * @param splitSearchKeyWord 検索キーワードの区別
     * @param andOrStr 検索条件のAND ,OR
     * @param showFieldName 検索結果の表示項目
     * @return 検索結果リスト
     */
     @TestVisible
    private static String searchSoql(
        String searchKeyWord, String ObjectName,
        String filedName,String relatedFiledname,
        String relatedFiledId,String addWhereCondtions,
        String orderByName,String limitStr,
        String splitSearchKeyWord,String andOrStr,String showFieldName
    )
    {
        //検索キーワード変数
        String searchKey = '';
        //検索キーワード変数が全角なら半角に変換してして、変数へ格納する
        String tempSplitSearchKeyWord = convertSplitKeyFullToHalf(splitSearchKeyWord);
        //
        if(tempSplitSearchKeyWord!='' && searchKeyWord!=null){
            String replaceKeyWord = convertSplitKeyHalfToFull(tempSplitSearchKeyWord);
            if(searchKeyWord.contains(replaceKeyWord)){
                searchKeyWord = searchKeyWord.replaceAll(replaceKeyWord, tempSplitSearchKeyWord);
                 
            }
            splitSearchKeyWord = tempSplitSearchKeyWord;
        }
        
        String relatedSearch=  String.isNotBlank(relatedFiledname) && String.isNotBlank(relatedFiledId) ? relatedFiledname+'='+'\''+relatedFiledId+'\'' : 'Id!=null';
        String addWhere =  String.isNotBlank(addWhereCondtions)?  addWhereCondtions :''  ;
        String orderBy = String.isNotBlank(orderByName) ?  orderByName :' LastViewedDate DESC'  ;
        List<String> keyWrods =new List<String>();             
        List<String> searchNames =new List<String>();
        
        if(searchKeyWord!=null){
            keyWrods = searchKeyWord.split(splitSearchKeyWord);
        }
        searchNames = filedName.trim().toLowerCase().split(',');
        if(andOrStr == 'and' && keyWrods.size() <= searchNames.size()){
          for(Integer i=0; i < keyWrods.size();i++){
                if(!string.isBlank(searchNames[i]) && !string.isBlank(keyWrods[i])){
                    searchKey+=' and ' + searchNames[i] +' LIKE '+'\''+'%'+keyWrods[i]+'%'+'\'';
                }
            }
        }
        if(andOrStr == 'or'){
            //List<String> searchStrs= new List<String>();
            for(String filed:searchNames){
                List<String> searchStrs= new List<String>();
                if(splitSearchKeyWord==''||splitSearchKeyWord==null){
                    searchStrs.add( filed +' LIKE '+'\''+'%'+keyWrods+'%'+'\'');
                    continue;                    
                }
                for(String keys : keyWrods){
                    if(String.isBlank(keys)) continue;
                    searchStrs.add( filed +' LIKE '+'\''+'%'+keys+'%'+'\'');
                }
                if(!searchStrs.isEmpty()){
                    searchKey +=' and ( '+String.join(searchStrs,' OR ')+ ' ) ';
                }
            }
            
            system.debug('searchKey:'+searchKey);
        }
        return 'select id,'+showFieldName+' from ' +ObjectName + ' where '+ relatedSearch  +searchKey+ addWhere +' order by '+orderBy+' limit '+limitStr;
    }
     public class wrapObject{
         @AuraEnabled 
        public sObject obj {get;set;}
         @AuraEnabled 
        public List<String> disPlayRow {get;set;}
        public wrapObject(sObject sobj,string filedName){
            this.obj=sobj;
            Integer i=0;
            disPlayRow = new  List<String>();
            for(String item:filedName.split(',')){
                if(i<2){
                    disPlayRow.add(String.valueOf(obj.get(item)));
                    i++;
                }
            }
        }
     }
     /**
     * 全角→半角変換メソッド
     *
     * @param splitKey 変換元文字列
     * @return 半角文字列
     */
    @TestVisible
    private static String convertSplitKeyFullToHalf(String splitKey) {
        String tempSplitKey=splitKey;
        Map<String, String> fulltoHalfMap = new Map<String, String>();
        fulltoHalfMap.put( '！',  '!' );
        fulltoHalfMap.put( '”',  '"' );
        fulltoHalfMap.put( '＃',  '#' );
        fulltoHalfMap.put( '＄',  '$' );
        fulltoHalfMap.put( '％',  '%' );
        fulltoHalfMap.put( '＆',  '&' );
        fulltoHalfMap.put(  '’',  '\'');
        fulltoHalfMap.put( '（',  '(' );
        fulltoHalfMap.put( '）',  ')' );
        fulltoHalfMap.put( '＊',  '*' );
        fulltoHalfMap.put( '＋',  '+' );
        fulltoHalfMap.put( '，',   '' );
        fulltoHalfMap.put( '−',  '-' );
        fulltoHalfMap.put( '．',  '.' );
        fulltoHalfMap.put( '／',  '/' );
        fulltoHalfMap.put( '：',  ':' );
        fulltoHalfMap.put( '；',  ';' );
        fulltoHalfMap.put( '＜',  '<' );
        fulltoHalfMap.put( '＝',  '=' );
        fulltoHalfMap.put( '＞',  '>' );
        fulltoHalfMap.put( '？',  '?' );
        fulltoHalfMap.put( '＠',  '@' );
        fulltoHalfMap.put( '［',  '[' );
        fulltoHalfMap.put(  '￥',  '\\');
        fulltoHalfMap.put( '］',  ']' );
        fulltoHalfMap.put( '＾',  '^' );
        fulltoHalfMap.put( '＿',  '_' );
        fulltoHalfMap.put( '‘',  '`' );
        fulltoHalfMap.put( '｛',  '{' );
        fulltoHalfMap.put( '｜',  '|' );
        fulltoHalfMap.put( '｝',  '}' );
        fulltoHalfMap.put( '〜',  '~' );
        fulltoHalfMap.put( '　',  ' ' );
        fulltoHalfMap.put( '。',  '｡' );
        fulltoHalfMap.put( '「',  '｢' );
        fulltoHalfMap.put( '」',  '｣' );
        fulltoHalfMap.put( '、',  '､' );
        fulltoHalfMap.put( '・',  '･' );
        fulltoHalfMap.put( '゛',  'ﾞ' );
        fulltoHalfMap.put( '゜',  'ﾟ' );
        if(fulltoHalfMap.containsKey(splitKey)){
            tempSplitKey = fulltoHalfMap.get(splitKey);         
        }
        return tempSplitKey;
    }
     /**
     * 半角→全角変換メソッド
     *
     * @param splitKey 変換元文字列
     * @return 全角文字列
     */
    @TestVisible
    private static String convertSplitKeyHalfToFull(String splitKey) {
        String tempSplitKey=splitKey;
        Map<String, String> halftoFullMap = new Map<String, String>();
        halftoFullMap.put('!' , '！');
        halftoFullMap.put('"' , '”');
        halftoFullMap.put('#' , '＃');
        halftoFullMap.put('$' , '＄');
        halftoFullMap.put('%' , '％');
        halftoFullMap.put('&' , '＆');
        halftoFullMap.put('\'' , '’');
        halftoFullMap.put('(' , '（');
        halftoFullMap.put(')' , '）');
        halftoFullMap.put('*' , '＊');
        halftoFullMap.put('+' , '＋');
        halftoFullMap.put('' , '，');
        halftoFullMap.put('-' , '−');
        halftoFullMap.put('.' , '．');
        halftoFullMap.put('/' , '／');
        halftoFullMap.put(':' , '：');
        halftoFullMap.put(';' , '；');
        halftoFullMap.put('<' , '＜');
        halftoFullMap.put('=' , '＝');
        halftoFullMap.put('>' , '＞');
        halftoFullMap.put('?' , '？');
        halftoFullMap.put('@' , '＠');
        halftoFullMap.put('[' , '［');
        halftoFullMap.put('\\' , '￥');
        halftoFullMap.put(']' , '］');
        halftoFullMap.put('^' , '＾');
        halftoFullMap.put('_' , '＿');
        halftoFullMap.put('`' , '‘');
        halftoFullMap.put('{' , '｛');
        halftoFullMap.put('|' , '｜');
        halftoFullMap.put('}' , '｝');
        halftoFullMap.put('~' , '〜');
        halftoFullMap.put(' ' , '　');
        halftoFullMap.put('｡' , '。');
        halftoFullMap.put('｢' , '「');
        halftoFullMap.put('｣' , '」');
        halftoFullMap.put('､' , '、');
        halftoFullMap.put('･' , '・');
        halftoFullMap.put('ﾞ' , '゛');
        halftoFullMap.put('ﾟ' , '゜');
        if(halftoFullMap.containsKey(splitKey)){
            tempSplitKey = halftoFullMap.get(splitKey);         
        }
        return tempSplitKey;
    }
}