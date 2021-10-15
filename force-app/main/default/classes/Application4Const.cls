/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）共通定数クラス
 *  クラス名       : Application4Const
 *  概要           : 申請（感染症拡大防止協力金：第3弾）共通定数クラス
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
public class Application4Const {
    
    /** 定数　バッチサイズ 200 */
    public static final Integer CONST_BATCH_SIZE = 200;

    /** 申請（第1弾）オブジェクト　ステータス　選択肢：支給決定 */
    public static final String CONST_APP1_STATUS_PAYMENT_DECISION = '支給決定';

    /** 申請（第2弾）オブジェクト　ステータス　選択肢：支給決定 */
    public static final String CONST_APP2_STATUS_PAYMENT_DECISION = '支給決定';

    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　ステータス　選択肢：未提出 */
    public static final String CONST_APP4_STATUS_NOT_PROPOSED = '未提出';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　ステータス　選択肢：審査待ち */
    public static final String CONST_APP4_STATUS_EXAMINATION = '審査待ち';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　ステータス　選択肢：不備回答待ち */
    public static final String CONST_APP4_STATUS_WAIT_ANSWER = '不備回答待ち';

    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　サブステータス　選択肢：新規申請 */
    public static final String CONST_APP4_SUB_STATUS_NEW = '新規申請';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　サブステータス　選択肢：再申請 */
    public static final String CONST_APP4_SUB_STATUS_REAPPLY = '再申請';
    
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　添付資料再提出状況　選択肢：再提出済み */
    public static final String CONST_APP4_DOCUMENT_REUPLOAD_REUPLOADED = '再提出済み';

    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　対象者区分　選択肢：個人事業主 */
    public static final String CONST_APP4_APP_DIV_SOLE = '個人事業主';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　対象者区分　選択肢：法人 */
    public static final String CONST_APP4_APP_DIV_CORP = '法人';
    
    /** 申請（第16弾）オブジェクト　申請タイプ　値：電子 */
    public static final String CONST_APP4_REP_FLG_ELECTRONIC = '電子';
    /** 申請（第16弾）オブジェクト　申請タイプ　値：紙 */
    public static final String CONST_APP4_REP_FLG_PAPER = '紙';

    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　要件審査結果　選択肢：審査OK */
    public static final String CONST_APP4_REQ_SCR_RET_OK = '審査OK';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　要件審査結果　選択肢：エスカレーション */
    public static final String CONST_APP4_REQ_SCR_RET_ESCA = 'エスカレーション';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　要件審査結果　選択肢：審査NG */
    public static final String CONST_APP4_REQ_SCR_RET_NG = '審査NG';

    /** 各審査チェックポイント項目の共通選択肢 */
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　各審査チェックポイント項目　共通選択肢：０：審査OK */
    public static final String CONST_APP4_SCR_RET_0_OK = '０：審査OK';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　各審査チェックポイント項目　共通選択肢：１：審査NG */
    public static final String CONST_APP4_SCR_RET_1_NG = '１：審査NG';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　各審査チェックポイント項目　共通選択肢：２：エスカレーション */
    public static final String CONST_APP4_SCR_RET_2_ESCA = '２：エスカレーション';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　各審査チェックポイント項目　共通選択肢：３：対象外 */
    public static final String CONST_APP4_SCR_RET_3_NOTSUB= '３：対象外';
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　各審査チェックポイント項目　共通選択肢：４：ファイル再提出 */
    public static final String CONST_APP4_SCR_RET_4_RESUB = '４：ファイル再提出';

    /** 申請入力画面　簡易申請申請選択リスト ラベル1：第1弾申請 */
    public static final String CONST_APP_SELECT_LIST_LABEL1 = '第1弾申請';
    /** 申請入力画面　簡易申請申請選択リスト ラベル2：第2弾申請 */
    public static final String CONST_APP_SELECT_LIST_LABEL2 = '第2弾申請';
    /** 申請入力画面　簡易申請申請選択リスト 値1：application1 */
    public static final String CONST_APP_SELECT_LIST_VALUE1 = 'application1';
    /** 申請入力画面　簡易申請申請選択リスト 値2：application1 */
     public static final String CONST_APP_SELECT_LIST_VALUE2 = 'application2';

    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　時短営業開始日：2020/12/7 */
    //public static final Date CONST_APP4_SHORTER_BUSI_START_DATE = Date.newinstance(2020,12,6);
    public static final Date CONST_APP4_SHORTER_BUSI_START_DATE = Date.valueOf(System.Label.STORE_START_DATE);
    /** 申請（感染症拡大防止協力金：第3弾）オブジェクト　時短営業終了日：2020/12/17 */
    //public static final Date CONST_APP4_SHORTER_BUSI_END_DATE = Date.newinstance(2020,12,18);
    public static final Date CONST_APP4_SHORTER_BUSI_END_DATE = Date.valueOf(System.Label.STORE_END_DATE);
    /** 日付のフォーマット yyyy/MM/dd */
    public static final String CONST_DATE_FMT = 'yyyy/MM/dd';

    /** 申請確認画面の時間短縮営業等実施期間の表示メッセージ */
    public static final String CONST_APP4_SHORTER_BUSI_PERIOD_MSG = '{0}　から　{1}まで（{2}日間）';
    
}