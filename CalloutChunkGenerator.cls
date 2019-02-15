/**
 * Created by Mathias on 26.07.16.
 */

public interface CalloutChunkGenerator {

    /**
     * Calculates and creates the required number of batch chunks for retrieving all company visits based on the
     * total of company visits
     */
    List<Fetcher.CalloutChunk> createChunksFromCompanyVisitsCount(Integer companyVisitsCount, Integer numberOfCompanyVisitsForEachChunk,
            Fetcher.IRange dateRange, Fetcher.JobType leadWebJobType);


}