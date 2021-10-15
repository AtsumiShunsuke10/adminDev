/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : ゴミ申請削除バッチスケジューラ
 *  クラス名       : Application4DeleteBatchScheduler
 *  概要           : ゴミ申請削除バッチスケジューラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
global class Application4DeleteBatchScheduler implements Schedulable {

    /**
     * Apex スケジュール済みジョブを実行します
     * 
     * @param System.SchedulableContext コンテキスト
     */
    global void execute(SchedulableContext sc) {
    
        // ゴミ申請削除バッチを呼び出す
        Application4DeleteBatch batch = new Application4DeleteBatch();
        Database.executeBatch(batch, Application4Const.CONST_BATCH_SIZE);
        
    }

}