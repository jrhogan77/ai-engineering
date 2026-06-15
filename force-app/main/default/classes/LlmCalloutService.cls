public with sharing class LlmCalloutService {

    private static final String API_PATH  = '/v1/messages';
    private static final Integer MAX_TOKENS = 2048;
    private static final Integer TIMEOUT_MS = 60000;

    public class LlmRequest {
        public String  namedCredential { get; set; }
        public String  model           { get; set; }
        public String  systemPrompt    { get; set; }
        public String  userMessage     { get; set; }
        public Integer maxTokens       { get; set; }

        public LlmRequest(String namedCredential, String model, String systemPrompt, String userMessage) {
            this.namedCredential = namedCredential;
            this.model           = model;
            this.systemPrompt    = systemPrompt;
            this.userMessage     = userMessage;
            this.maxTokens       = MAX_TOKENS;
        }
    }

    public class LlmResponse {
        public Boolean success       { get; set; }
        public String  content       { get; set; }
        public String  errorMessage  { get; set; }
        public String  model         { get; set; }
        public Integer inputTokens   { get; set; }
        public Integer outputTokens  { get; set; }
    }

    public static LlmResponse complete(LlmRequest request) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + request.namedCredential + API_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept',       'application/json');
        req.setTimeout(TIMEOUT_MS);
        req.setBody(buildPayload(request));

        HttpResponse res = new Http().send(req);
        return parseResponse(res);
    }

    private static String buildPayload(LlmRequest request) {
        return JSON.serialize(new Map<String,Object>{
            'model'      => request.model,
            'max_tokens' => request.maxTokens,
            'system'     => request.systemPrompt,
            'messages'   => new List<Map<String,Object>>{
                new Map<String,Object>{ 'role' => 'user', 'content' => request.userMessage }
            }
        });
    }

    private static LlmResponse parseResponse(HttpResponse res) {
        LlmResponse response  = new LlmResponse();
        response.success      = (res.getStatusCode() >= 200 && res.getStatusCode() < 300);

        if (!response.success) {
            response.errorMessage = 'HTTP ' + res.getStatusCode() + ': ' + res.getBody();
            return response;
        }

        Map<String,Object> body = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

        List<Object> contentBlocks = (List<Object>) body.get('content');
        if (contentBlocks != null && !contentBlocks.isEmpty()) {
            Map<String,Object> block = (Map<String,Object>) contentBlocks[0];
            response.content = (String) block.get('text');
        }

        response.model = (String) body.get('model');

        Map<String,Object> usage = (Map<String,Object>) body.get('usage');
        if (usage != null) {
            response.inputTokens  = (Integer) usage.get('input_tokens');
            response.outputTokens = (Integer) usage.get('output_tokens');
        }

        return response;
    }
}
