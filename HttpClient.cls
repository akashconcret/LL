/**
 * HTTP Client adapted from Cumulocity.
 */
public with sharing class HttpClient implements Service {

    public interface Service {
        String doGetBasicAuth(String url, String pfad, Map<String, String> parameter, String benutzername,
                              String passwort);
        String doGet(String url, String pfad, Map<String, String> parameter, String contentType);
        String doPost(String url, String pfad, String Body, String method, String contentType);
    }

    /**
     * Execute a GET request.
     * @param url URL of the request
     * @param pfad Context path of the request
     * @param parameter Parameter of the request
     * @param benutzername Username
     * @param passwort password
     * @param certName Certificate name
     * @return ResponseDto Result of the request
     */
    public String doGetBasicAuth(String url, String pfad, Map<String, String> parameter,
                                 String benutzername, String passwort) {
        HttpRequest request = doCommon(url, pfad, parameter, 'GET', 'application/xml');

        //Set the authentication header
        erstellteAuthHeader(benutzername, passwort, request);
        Http http = new Http();

        //Handle the response
        HTTPResponse response = http.send(request);
        return behandleAntwort(response);
    }

    public String doGet(String url, String pfad, Map<String, String> parameter, String contentType) {
        HttpRequest request = doCommon(url, pfad, parameter, Constants.GET_METHOD, contentType);
        Http http = new Http();
        HTTPResponse response = http.send(request);
		system.debug('httprequest :: '+request);
        return behandleAntwort(response);
    }

    public String doPost(String url, String pfad, String body, String method, String contentType) {
        Http http = new Http();

        HttpRequest request = doCommon(url, pfad, null, Constants.POST_METHOD, contentType);

        request.setBody(body);
        request.setHeader('Content-Length', String.valueOf(body.length()));

        HTTPResponse response = http.send(request);

        return behandleAntwort(response);
    }

    /**
     * Set the parameters of the request.
     * @param url URL of the request
     * @param pfad Context path of the request
     * @param parameter Parameter of the request
     * @param benutzername Username
     * @param passwort password
     * @param HTTP-Methode
     * @return HttpRequest request object with the parameters set.
     */
    private HttpRequest doCommon(String url, String pfad, Map<String, String> parameter, String method,
                                 String contentType) {
        HttpRequest request = new HttpRequest();
        // Set the endpoint
        request.setEndpoint(erstellePfad(url, pfad, parameter));
        request.setMethod(method);
        request.setTimeout(120000);
        if(contentType != null)
            request.setHeader('Content-Type' , contentType);
        return request;
    }

    /**
     * Erzeugt die vollstaendige Aufruf-url
     * Create the full callout URL
     * @param url URL of the request
     * @param pfad Context path of the request
     * @param parameter Parameter of the request
     * @return String The full path
     */
    private String erstellePfad(String url, String pfad, Map<String, String> parameter) {
        String aufrufurl = '';
        // Ensure the URL ends with a "/"
        if(url != null && pfad != null) {
            if(url.endsWith('/') && pfad.startsWith('/'))
                aufrufurl += url.substring(0, url.length() - 1);
            else if(!url.endsWith('/') && !pfad.startsWith('/')) {
                aufrufurl += url;
                aufrufurl += '/';
            } else
                aufrufurl += url;
        }
        // Added the parameters if they're provided, otherwise just the path
        if(parameter != null && !parameter.isEmpty()) {
            // Delete "/" in the path if it exists
            if(pfad.endsWith('/'))
                aufrufurl += pfad.substring(0, pfad.length() - 1);
            else
                aufrufurl += pfad;
            aufrufurl += '?';
            Integer i = 0;
            // Iteration of parameters and addition to URL
            for(String param : parameter.keySet()) {
                i += 1;
                aufrufurl += param;
                aufrufurl += '=';
                aufrufurl += parameter.get(param);
                if(i < parameter.size())
                    aufrufurl += '&';
            }
        } else
            aufrufurl += pfad;
        return aufrufurl;
    }

    /**
     * Set the authorization header for the request
     * @param benutzername Username
     * @param passwort password
     * @param request HttpRequest
     */
    private void erstellteAuthHeader(String benutzername, String passwort, Httprequest request) {
        String wert = benutzername + ':' + passwort;
        wert = 'Basic ' + EncodingUtil.base64Encode(Blob.valueof(wert));
        request.setHeader('Authorization', wert);
    }

    /**
     * Return the result of the call based on the HTTP status.
     * @param response Response object of the http request
     * @return String Response body if we receive a 200 - OK
     *
     * @throws Exceptions.HttpException
     */
    private String behandleAntwort(HttpResponse response) {
        // Bei HttpStatus 200 wird die JSON-Repraesentation des Dtos des aufgerufenen Rest Services zurueckgegeben
        if(response.getStatusCode() == 200 || response.getStatusCode() == 509) {
            return response.getBody().replace('""', 'null');
            // Ist der Http Status nicht 200, wird eine Exception geworfen
        } else if(response.getStatusCode() == 403)
            throw new Exceptions.Http403Exception(response.getBody());
        else if(response.getStatusCode() == 405)
            throw new Exceptions.Http405Exception(response.getBody());
        else if(response.getStatusCode() == 429){
            throw new Exceptions.Http429Exception(response.getBody());
        // else if(response.getStatusCode() == 509){
             // throw new Exceptions.Http509Exception(response.getBody());
        }else{
            throw new Exceptions.HttpException(response.getBody());
        }
    }


    private HTTPClient() {}

    /**
     * Singleton constructor for this class.
     */
    public static HTTPClient.Service getinstance() {
        return new HttpClient();
    }


}