public with sharing class CalloutChunkFactory implements CalloutChunkGenerator {

    public List<Fetcher.CalloutChunk> createChunksFromCompanyVisitsCount(Integer companyVisitsCount, Integer numberOfCompanyVisitsForEachChunk,
            Fetcher.IRange dateRange, Fetcher.JobType leadWebJobType) {

        List<Fetcher.CalloutChunk> chunkList = new List<Fetcher.CalloutChunk>();
        Integer chunkStartIndex = 0;
        for (Integer chunkIndex = 0; chunkIndex < calculateRequiredNumberOfChunks(companyVisitsCount, numberOfCompanyVisitsForEachChunk); chunkIndex++) {
            Fetcher.CalloutChunk newChunk = new Fetcher.CalloutChunk(leadWebJobType, dateRange.getStart(), dateRange.getFinish(),
                    chunkStartIndex, numberOfCompanyVisitsForEachChunk);
            chunkList.add(newChunk);
            chunkStartIndex += numberOfCompanyVisitsForEachChunk;
        }
        return chunkList;
    }

    /**
     * Calculates the number of required chunks based on the total number of visits and the visits for each chunk
     * In case the division returns a remainder an extra chunk is created for the rest of the visits
     */
    private Integer calculateRequiredNumberOfChunks(Decimal companyVisitsCount, Decimal numberOfCompanyVisitsForEachChunk) {
        return (Integer) (companyVisitsCount / numberOfCompanyVisitsForEachChunk).round(RoundingMode.CEILING);
    }

}