/**
 * Created by Mathias on 03.02.16.
 */

public with sharing class loli_utils_BatchStubCallback implements Database.Batchable<Integer>, Database.Stateful {

    public Interface BatchStubTestCallback {

        void onExecute(List<Integer> scope);

        void onFinish();

    }

    public List<Integer> batchProcessingList { get; private set; }
    private BatchStubTestCallback callBack { get; private set; }

    public loli_utils_BatchStubCallback(List<Integer> batchProcessingList, BatchStubTestCallback callback) {
        this.batchProcessingList = batchProcessingList;
        this.callback = callBack;
    }


    public List<Integer> start(Database.BatchableContext bc) {
        return batchProcessingList;
    }


    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        callBack.onExecute(scope);
    }

    public void finish(Database.BatchableContext bc) {
        callBack.onFinish();
    }
}