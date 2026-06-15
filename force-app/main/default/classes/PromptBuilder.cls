public with sharing class PromptBuilder {

    private String       systemContext;
    private List<String> contextBlocks = new List<String>();
    private List<String> constraints   = new List<String>();
    private String       instruction;
    private String       outputFormat;

    public PromptBuilder withSystemContext(String context) {
        this.systemContext = context;
        return this;
    }

    public PromptBuilder withContext(String label, String value) {
        if (String.isNotBlank(value)) {
            contextBlocks.add(label + ': ' + value);
        }
        return this;
    }

    public PromptBuilder withConstraint(String constraint) {
        if (String.isNotBlank(constraint)) {
            constraints.add(constraint);
        }
        return this;
    }

    public PromptBuilder withInstruction(String instruction) {
        this.instruction = instruction;
        return this;
    }

    public PromptBuilder withOutputFormat(String format) {
        this.outputFormat = format;
        return this;
    }

    public String buildSystemPrompt() {
        List<String> parts = new List<String>();
        if (String.isNotBlank(systemContext)) {
            parts.add(systemContext);
        }
        if (!constraints.isEmpty()) {
            parts.add('CONSTRAINTS:\n- ' + String.join(constraints, '\n- '));
        }
        return String.join(parts, '\n\n');
    }

    public String buildUserMessage() {
        List<String> parts = new List<String>();
        if (!contextBlocks.isEmpty()) {
            parts.add('CONTEXT:\n' + String.join(contextBlocks, '\n'));
        }
        if (String.isNotBlank(instruction)) {
            parts.add('INSTRUCTION:\n' + instruction);
        }
        if (String.isNotBlank(outputFormat)) {
            parts.add('OUTPUT FORMAT:\n' + outputFormat);
        }
        return String.join(parts, '\n\n');
    }
}
