@isTest
public class TestHTTPClient {

    static HTTPClient.Service client;

    /**
     * Testvorbereitungen
     */
    private static void prepare() {
        client = HTTPClient.getinstance();

    }

    /**
     * Fakes http response
     */
    public class RespondMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // only send a mock response for a specific endpoint and method.
            System.assertEquals(Constants.DEFAULT_ENDPOINT + '/foo/bar?endzeilen=20&startzeilen=10',
                                req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class PostMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // only send a mock response for a specific endpoint and method.
            System.assertEquals(Constants.DEFAULT_ENDPOINT + '/foo/bar',
                                req.getEndpoint());
            System.assertEquals('POST', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
      * Testen von doGetBasicAuth
      */
    static TestMethod void testdoGetBasicAuth() {
        Test.setMock(HttpCalloutMock.class, new RespondMock());
        prepare();
        // Aufrufdaten erzeugen
        Map<String, String> parameter = new Map<String, String> {'endzeilen' => '20', 'startzeilen' => '10'};
        String res = client.doGetBasicAuth(Constants.DEFAULT_ENDPOINT, 'foo/bar', parameter, 'admin',
                                           'admin1234');

        // Pruefen, dass HTTPRequest korrekt erstellt wurde
        System.assert(res != null);
        System.assertEquals('{"foo":"bar"}', res);
    }

    @isTest static void testDoPost() {
        Test.setMock(HttpCalloutMock.class, new PostMock());
        prepare();
        // Aufrufdaten erzeugen
        Map<String, String> parameter = new Map<String, String> {'endzeilen' => '20', 'startzeilen' => '10'};
        String res = client.doPost(Constants.DEFAULT_ENDPOINT, 'foo/bar', '{"foo":"bar"}', 'POST',
                                   'admin1234');

        // Pruefen, dass HTTPRequest korrekt erstellt wurde
        System.assert(res != null);
        System.assertEquals('{"foo":"bar"}', res);

    }
}