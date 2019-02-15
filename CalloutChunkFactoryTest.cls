@isTest
public with sharing class CalloutChunkFactoryTest {

    private static CalloutChunkFactory chunkFactory;

    private static void setup() {
        chunkFactory = new CalloutChunkFactory();
    }


    //---- createChunksFromCompanyVisitsCount ----//

    private static List<Fetcher.CalloutChunk> chunksExpected_createChunksFromCompanyVisitsCount;
    private static Integer numberOfCompanyVisits_createChunksFromCompanyVisitsCount = 1000;
    private static Integer numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount = 100;
    private static Integer numberOfChunks_createChunksFromCompanyVisitsCount = 10;
    private static Fetcher.IRange timeRange_createChunksFromCompanyVisitsCount = new Fetcher.DateRange(Date.today().addDays(-15), Date.today());
    private static Fetcher.JobType batchJobType_createChunksFromCompanyVisitsCount = Fetcher.JobType.GetCompanies;

    private static void setup_createChunksFromCompanyVisitsCount() {
        setup();
        chunksExpected_createChunksFromCompanyVisitsCount = prepareCalloutChunks(numberOfChunks_createChunksFromCompanyVisitsCount,
                numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount, timeRange_createChunksFromCompanyVisitsCount, batchJobType_createChunksFromCompanyVisitsCount);
    }

    private static List<Fetcher.CalloutChunk> prepareCalloutChunks(Integer numberofChunks, Integer numberOfVisitsForEachChunk, Fetcher.IRange dateRange, Fetcher.JobType batchJobType) {
        List<Fetcher.CalloutChunk> chunkList = new List<Fetcher.CalloutChunk>();
        Integer chunkStart = 0;
        for (Integer chunkIndex = 0; chunkIndex < numberofChunks; chunkIndex++) {
            Fetcher.CalloutChunk newChunk = new Fetcher.CalloutChunk(batchJobType, dateRange.getStart(), dateRange.getFinish(), chunkStart, numberOfVisitsForEachChunk);
            chunkList.add(newChunk);
            chunkStart += numberOfVisitsForEachChunk;
        }
        return chunkList;
    }


    private static TestMethod void calculatesAndReturnsRequiredListOfChunksForANumberOfVisitsAndChunksSize() {
        setup_createChunksFromCompanyVisitsCount();

        List<Fetcher.CalloutChunk> returnedCalloutChunks = chunkFactory.createChunksFromCompanyVisitsCount(numberOfCompanyVisits_createChunksFromCompanyVisitsCount,
                numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount, timeRange_createChunksFromCompanyVisitsCount, batchJobType_createChunksFromCompanyVisitsCount);

        System.assert(returnedCalloutChunks != null);
        System.assertEquals(10, returnedCalloutChunks.size());
        System.assertEquals(chunksExpected_createChunksFromCompanyVisitsCount, returnedCalloutChunks);
    }

    private static TestMethod void calculatesAndReturnsRequiredListOfChunksWithAnAdditionChunkInCaseOfUnequalsDevision() {
        setup_createChunksFromCompanyVisitsCount();

        numberOfCompanyVisits_createChunksFromCompanyVisitsCount = 1005;
        numberOfChunks_createChunksFromCompanyVisitsCount = 11;
        chunksExpected_createChunksFromCompanyVisitsCount = prepareCalloutChunks(numberOfChunks_createChunksFromCompanyVisitsCount,
                numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount, timeRange_createChunksFromCompanyVisitsCount, batchJobType_createChunksFromCompanyVisitsCount);

        List<Fetcher.CalloutChunk> returnedCalloutChunks = chunkFactory.createChunksFromCompanyVisitsCount(numberOfCompanyVisits_createChunksFromCompanyVisitsCount,
                numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount, timeRange_createChunksFromCompanyVisitsCount, batchJobType_createChunksFromCompanyVisitsCount);

        System.assert(returnedCalloutChunks != null);
        System.assertEquals(11, returnedCalloutChunks.size());
        System.assertEquals(chunksExpected_createChunksFromCompanyVisitsCount, returnedCalloutChunks);
    }

    private static TestMethod void returnsASingleChunkWhenTotalNumberOfVisitsFitIntoOneChunk() {
        setup_createChunksFromCompanyVisitsCount();

        numberOfCompanyVisits_createChunksFromCompanyVisitsCount = 10;

        List<Fetcher.CalloutChunk> returnedCalloutChunks = chunkFactory.createChunksFromCompanyVisitsCount(numberOfCompanyVisits_createChunksFromCompanyVisitsCount,
                numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount, timeRange_createChunksFromCompanyVisitsCount, batchJobType_createChunksFromCompanyVisitsCount);

        System.assert(returnedCalloutChunks != null);
        System.assertEquals(1, returnedCalloutChunks.size());
    }

    private static TestMethod void returnsZeroChunksWhenNoVisitsAreAvailable() {
        setup_createChunksFromCompanyVisitsCount();

        numberOfCompanyVisits_createChunksFromCompanyVisitsCount = 0;

        List<Fetcher.CalloutChunk> returnedCalloutChunks = chunkFactory.createChunksFromCompanyVisitsCount(numberOfCompanyVisits_createChunksFromCompanyVisitsCount,
                numberOfVisitsForEachChunk_createChunksFromCompanyVisitsCount, timeRange_createChunksFromCompanyVisitsCount, batchJobType_createChunksFromCompanyVisitsCount);

        System.assert(returnedCalloutChunks != null);
        System.assertEquals(0, returnedCalloutChunks.size());
    }




}