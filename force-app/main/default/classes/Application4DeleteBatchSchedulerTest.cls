/*******************************************************************************
 *  プロジェクト名 : 神奈川県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : ゴミ申請削除バッチスケジューラテストクラス
 *  クラス名       : Application4DeleteBatchSchedulerTest
 *  概要           : ゴミ申請削除バッチスケジューラテストクラス
 *  作成者         : 李
 *  作成日         : 2020/12/21
 *******************************************************************************/
@isTest 
public class Application4DeleteBatchSchedulerTest {
    
    /**
     * テストケース１
     * 
     */
    @isTest 
    static void unitTest1() {
        
        Test.startTest();
        
        // 実行予定日時:毎年1月1日の朝2時
        String CRON_EXP = '0 0 2 1 1 ?';
        // スゲージュルを実行
        System.schedule('申請（感染症拡大防止協力金：第3弾）削除バッチスケジューラ', CRON_EXP, new Application4DeleteBatchScheduler());
        
        Test.stopTest();
        
    }
    
}