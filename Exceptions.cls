public with sharing class Exceptions {
    public class Http500Exception extends Exception{}
    public class Http403Exception extends Exception{}
    public class Http405Exception extends Exception{}
    public class Http429Exception extends Exception{}
    public class Http509Exception extends Exception{}
    
    public class HttpException extends Exception{}
    
    public class CustomMandatoryFieldsException extends Exception{}
}