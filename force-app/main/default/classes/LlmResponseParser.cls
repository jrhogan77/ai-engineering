public with sharing class LlmResponseParser {

    public class ParseResult {
        public Boolean success      { get; set; }
        public Object  parsedValue  { get; set; }
        public String  rawContent   { get; set; }
        public String  errorMessage { get; set; }
    }

    public static ParseResult parseJson(String content) {
        ParseResult result  = new ParseResult();
        result.rawContent   = content;

        String block = extractJsonBlock(content);
        if (String.isBlank(block)) {
            result.success      = false;
            result.errorMessage = 'No JSON block found in LLM response';
            return result;
        }

        try {
            result.parsedValue = JSON.deserializeUntyped(block);
            result.success     = true;
        } catch (JSONException e) {
            result.success      = false;
            result.errorMessage = 'JSON parse error: ' + e.getMessage();
        }

        return result;
    }

    public static ParseResult parseText(String content) {
        ParseResult result  = new ParseResult();
        result.rawContent   = content;
        result.parsedValue  = content != null ? content.trim() : '';
        result.success      = String.isNotBlank(content);
        if (!result.success) {
            result.errorMessage = 'LLM returned empty content';
        }
        return result;
    }

    public static ParseResult parseList(String content) {
        ParseResult result = parseJson(content);
        if (!result.success) return result;

        if (!(result.parsedValue instanceof List<Object>)) {
            result.success      = false;
            result.errorMessage = 'Expected a JSON array but received an object';
            result.parsedValue  = null;
        }
        return result;
    }

    private static String extractJsonBlock(String content) {
        if (String.isBlank(content)) return null;
        Integer start = content.indexOf('{');
        Integer startArr = content.indexOf('[');
        if (startArr != -1 && (start == -1 || startArr < start)) {
            Integer end = content.lastIndexOf(']');
            return (end > startArr) ? content.substring(startArr, end + 1) : null;
        }
        Integer end = content.lastIndexOf('}');
        return (start != -1 && end > start) ? content.substring(start, end + 1) : null;
    }
}
