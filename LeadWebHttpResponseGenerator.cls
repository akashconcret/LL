@isTest
global class LeadWebHttpResponseGenerator implements HttpCalloutMock {
    string resp;
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(string.valueof(req.getEndPoint()).contains('legalforms')){
            resp = '{"code":200,"ts":1486099942,"data":[{"legalForm":"A G","cc2":"de","fastMatch":"a g","reversedFastMatch":"g a","length":3}]}';
        }else{
            resp = '{"code":200,"ts":1486033608,"data":{"publicCustnum":"6d2b90040e197455","lastUpdate":1486033382,"lastRequest":1486033607,"pisCurrent":2156,"detectedCompanies":55,"limitReached":false,"fromTime":1485216000,"toTime":1485388800,"start":250,"length":5,"resultSize":251,"hasMore":false,"companies":[{"id":"e7cdec7c41023cd77f2478891316b82e","name":"kokoios corp.","domain":"kokoios.co.jp","street":null,"houseNumber":null,"zip":"103-0013","city":"Tokyo","region":"Tokyo","countryCode2":"JP","countryName":"Japan","phone":null,"fax":null,"email":null,"branch":null,"branchWz2008":null,"size":null,"revenue":null,"ddate":1485216747,"pis":1,"duration":0,"searchPhrases":null,"pages":[{"name":"WM_CT_DE_de|","pis":1}],"milestones":[],"campaigns":[],"userId":"1253797","cdId":null}]}}';
        }
         
        res.setBody(resp);
        res.setStatusCode(200); 
        system.assertEquals(200,res.getStatusCode());
        return res;
    } 
}