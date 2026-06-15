public with sharing class AiOrchestrationService {

    @InvocableMethod(
        label='Run AI Analysis'
        description='Sends a structured, grounded prompt to the configured LLM and returns the response for use in Flow'
    )
    public static List<Result> runAnalysis(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result result = new Result();
            try {
                PromptBuilder builder = new PromptBuilder()
                    .withSystemContext(req.systemContext)
                    .withContext('Record Name',         req.recordName)
                    .withContext('Additional Context',  req.additionalContext)
                    .withConstraint('Return only information grounded in the provided context')
                    .withConstraint('Do not fabricate or infer information not present in the context')
                    .withInstruction(req.instruction)
                    .withOutputFormat(req.outputFormat);

                LlmCalloutService.LlmRequest llmReq = new LlmCalloutService.LlmRequest(
                    req.namedCredential,
                    req.model,
                    builder.buildSystemPrompt(),
                    builder.buildUserMessage()
                );

                LlmCalloutService.LlmResponse llmRes = LlmCalloutService.complete(llmReq);

                if (llmRes.success) {
                    Boolean expectJson = String.isNotBlank(req.outputFormat)
                        && req.outputFormat.containsIgnoreCase('JSON');

                    LlmResponseParser.ParseResult parsed = expectJson
                        ? LlmResponseParser.parseJson(llmRes.content)
                        : LlmResponseParser.parseText(llmRes.content);

                    result.success      = parsed.success;
                    result.responseText = String.valueOf(parsed.parsedValue);
                    result.errorMessage = parsed.errorMessage;
                    result.inputTokens  = llmRes.inputTokens;
                    result.outputTokens = llmRes.outputTokens;
                } else {
                    result.success      = false;
                    result.errorMessage = llmRes.errorMessage;
                }

            } catch (Exception e) {
                result.success      = false;
                result.errorMessage = e.getTypeName() + ': ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(label='Named Credential'    description='API name of the Named Credential for the LLM endpoint' required=true)
        public String namedCredential;

        @InvocableVariable(label='Model'               description='LLM model identifier' required=true)
        public String model;

        @InvocableVariable(label='System Context'      description='System-level role and behavioral instructions for the LLM')
        public String systemContext;

        @InvocableVariable(label='Record Name'         description='Name of the Salesforce record for contextual grounding')
        public String recordName;

        @InvocableVariable(label='Additional Context'  description='Supporting data to inject into the prompt')
        public String additionalContext;

        @InvocableVariable(label='Instruction'         description='The specific task instruction for the LLM' required=true)
        public String instruction;

        @InvocableVariable(label='Output Format'       description='Requested output format — plain text or JSON')
        public String outputFormat;
    }

    public class Result {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Response Text')
        public String responseText;

        @InvocableVariable(label='Error Message')
        public String errorMessage;

        @InvocableVariable(label='Input Tokens Used')
        public Integer inputTokens;

        @InvocableVariable(label='Output Tokens Used')
        public Integer outputTokens;
    }
}
