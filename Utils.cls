public with sharing class Utils {

    private static Map<String, String> foldingAsciiMap = new Map<String, String> {
        'À' => 'A',
        'à' => 'a',
        'Á' => 'A',
        'á' => 'a',
        'Â' => 'A',
        'â' => 'a',
        'Ã' => 'A',
        'ã' => 'a',
        'Ä' => 'A',
        'ä' => 'a',
        'Å' => 'A',
        'å' => 'a',
        'Æ' => 'A',
        'æ' => 'a',
        'Ā' => 'A',
        'ā' => 'a',
        'Ă' => 'A',
        'ă' => 'a',
        'Ą' => 'A',
        'ą' => 'a',

        'Ç' => 'C',
        'ç' => 'c',
        'Ć' => 'C',
        'ć' => 'c',
        'Ĉ' => 'C',
        'ĉ' => 'c',
        'Ċ' => 'C',
        'ċ' => 'c',
        'Č' => 'C',
        'č' => 'c',

        'Ď' => 'D',
        'ď' => 'd',
        'Đ' => 'D',
        'đ' => 'd',

        'È' => 'E',
        'è' => 'e',
        'É' => 'E',
        'é' => 'e',
        'Ê' => 'E',
        'ê' => 'e',
        'Ë' => 'E',
        'ë' => 'e',
        'Ð' => 'E',
        'ð' => 'e',
        'Ē' => 'E',
        'ē' => 'e',
        'Ĕ' => 'E',
        'ĕ' => 'e',
        'Ė' => 'E',
        'ė' => 'e',
        'Ę' => 'E',
        'ę' => 'e',
        'Ě' => 'E',
        'ě' => 'e',

        'Ĝ' => 'G',
        'ĝ' => 'g',
        'Ğ' => 'G',
        'ğ' => 'g',
        'Ġ' => 'G',
        'ġ' => 'g',
        'Ģ' => 'G',
        'ģ' => 'g',

        'Ĥ' => 'H',
        'ĥ' => 'h',
        'Ħ' => 'H',
        'ħ' => 'h',

        'Ì' => 'I',
        'ì' => 'i',
        'Í' => 'I',
        'í' => 'i',
        'Î' => 'I',
        'î' => 'i',
        'Ï' => 'I',
        'ï' => 'i',
        'Ĩ' => 'I',
        'ĩ' => 'i',
        'Ī' => 'I',
        'ī' => 'i',
        'Ĭ' => 'I',
        'ĭ' => 'i',
        'Į' => 'I',
        'į' => 'i',
        'İ' => 'I',
        'ı' => 'i',
        'Ĳ' => 'I',
        'ĳ' => 'i',

        'Ĵ' => 'J',
        'ĵ' => 'j',

        'Ķ' => 'K',
        'ķ' => 'k',
        'ĸ' => 'k',

        'Ĺ' => 'L',
        'ĺ' => 'l',
        'Ļ' => 'L',
        'ļ' => 'l',
        'Ľ' => 'L',
        'ľ' => 'l',
        'Ŀ' => 'L',
        'ŀ' => 'l',
        'Ł' => 'L',
        'ł' => 'l',

        'Ń' => 'N',
        'ń' => 'n',
        'Ņ' => 'N',
        'ņ' => 'n',
        'Ň' => 'N',
        'ň' => 'n',
        'ŉ' => 'n',
        'Ŋ' => 'N',
        'ŋ' => 'n',
        'Ñ' => 'N',
        'ñ' => 'n',

        'Ò' => 'O',
        'ò' => 'o',
        'Ó' => 'O',
        'ó' => 'o',
        'Ô' => 'O',
        'ô' => 'o',
        'Ò' => 'O',
        'õ' => 'o',
        'Ö' => 'O',
        'ö' => 'o',
        'Ø' => 'O',
        'ø' => 'o',
        'Ō' => 'O',
        'ō' => 'o',
        'Ŏ' => 'O',
        'ŏ' => 'o',
        'Ő' => 'O',
        'ő' => 'o',
        'Œ' => 'O',
        'œ' => 'o',

        'þ' => 'P',

        'Ŕ' => 'R',
        'ŕ' => 'r',
        'Ŗ' => 'R',
        'ŗ' => 'r',
        'Ř' => 'R',
        'ř' => 'r',

        'Ś' => 'S',
        'ś' => 's',
        'Ŝ' => 'S',
        'ŝ' => 's',
        'Ş' => 'S',
        'ş' => 's',
        'Š' => 'S',
        'š' => 's',
        'ß' => 's',
        'ſ' => 's',

        'Ţ' => 'T',
        'ţ' => 't',
        'Ť' => 'T',
        'ť' => 't',
        'Ŧ' => 'T',
        'ŧ' => 't',

        'Ũ' => 'U',
        'ũ' => 'u',
        'Ū' => 'U',
        'ū' => 'u',
        'Ŭ' => 'U',
        'ŭ' => 'u',
        'Ů' => 'U',
        'ů' => 'u',
        'Ű' => 'U',
        'ű' => 'u',
        'Ų' => 'U',
        'ų' => 'u',
        'Ù' => 'U',
        'ù' => 'u',
        'Ú' => 'U',
        'ú' => 'u',
        'Û' => 'U',
        'û' => 'u',
        'Ü' => 'U',
        'ü' => 'u',

        'Ŵ' => 'W',
        'ŵ' => 'w',

        'Ŷ' => 'Y',
        'ŷ' => 'y',
        'Ý' => 'Y',
        'ý' => 'y',
        'Ÿ' => 'Y',
        'ÿ' => 'y',

        'Ź' => 'Z',
        'ź' => 'z',
        'Ż' => 'Z',
        'ż' => 'z',
        'Ž' => 'Z',
        'ž' => 'z'
    };
    private static String nonAscii = String.join(new List<String>
                                     (foldingAsciiMap.keySet()), '');

    /**
    *Performs ASCII folding for source string
    *@param source : String for converting
    *@return converted String
    */
    public static String asciiFolding(String source) {
        if(String.isEmpty(source) || source.isAsciiPrintable() ||
           !source.containsAny(nonAscii))
            return source;

        final Set<String> nonAsciiChars = new Set<String>(source.split(''));
        nonAsciiChars.retainAll(foldingAsciiMap.keySet());

        for(String key : nonAsciiChars)
            source = source.replaceAll(key, foldingAsciiMap.get(key));
        return source;
    }

    /**
     * Checks if a scheduled job with the given name already exists.
     *
     * @param name: of the cronjob
     * @return: true if job exists, else false
     */
    public static Boolean cronJobExists(String cronjobName) {
        List<CronJobDetail> jobs = [Select Name from CronJobDetail where Name = :
                                    cronjobName];

        if(!jobs.isEmpty() && jobs.size() == 1)
            return true;
        else
            return false;
    }

    /**
    *   Validate object and fields is accessible for user
    *   @return: list is empty if object and fields accessible, else list is not empty
    */

    public static List<String> isAccessible(sObject objectName,
                                            List<String> fieldList) {
        Schema.sObjectType sobjectType = objectName.getSObjectType();
        Schema.DescribeSobjectResult objDescribe = sobjectType.getDescribe();
        List<String> issuesAccessible = new List<String>();
        if(objDescribe.isAccessible() == false) {
            issuesAccessible.add(Label.Object + ' ' + objDescribe.getLabel() + ' ' +
                                 Label.IsNotAccessible);
            return issuesAccessible;
        }
        Map<String, Schema.SObjectField> objFields = objDescribe.fields.getMap();

        if(fieldList != null) {
            for(String f : fieldList) {
                if(objFields.containsKey(f.trim())) {
                    if(objFields.get(f.trim()).getDescribe().isAccessible() == false)
                        issuesAccessible.add(Label.Field + ' ' + f + ' ' + Label.IsNotAccessible);
                }
            }
        }
        return issuesAccessible;
    }

}