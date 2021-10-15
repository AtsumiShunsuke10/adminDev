/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : ゴミ申請削除バッチスケジューラ
 *  クラス名       : Application15DeleteBatchScheduler
 *  概要           : ゴミ申請削除バッチスケジューラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
global class Application15DeleteBatchScheduler implements Schedulable {

    /**
     * Apex スケジュール済みジョブを実行します
     * 
     * @param System.SchedulableContext コンテキスト
     */
    global void execute(SchedulableContext sc) {
    
        // ゴミ申請削除バッチを呼び出す
        Application15DeleteBatch batch = new Application15DeleteBatch();
        Database.executeBatch(batch, Application15Const.CONST_BATCH_SIZE);
        
    }

}