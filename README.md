# AI Engineering
### Enterprise AI on the Salesforce Platform

This repository demonstrates applied AI engineering within the Salesforce ecosystem — not theoretical capability, but production tooling actively in use. The focus is on LLM integration, intelligent process automation, and AI-augmented development workflows that deliver measurable outcomes at enterprise scale.

---

## Engineering Philosophy

AI is not a feature you bolt on. It is an architectural layer you design for from the start — with defined boundaries, controlled inputs, observable outputs, and fallback behavior when models underperform. Every integration here reflects that discipline.

**What this is not:**
- Prompt copy-paste from a tutorial
- Einstein feature configuration
- GPT wrappers with no engineering behind them

**What this is:**
- Structured AI orchestration with defined input/output contracts
- Proprietary constraint and grounding systems (methodology is private IP — architecture patterns are shown)
- Production-deployed tooling, not proof-of-concept demos

---

## Integration Patterns

### LLM Integration via Apex
Salesforce Apex as the orchestration layer for LLM API calls — structured prompts, typed responses, error handling, and token-aware request management.

```
classes/
├── LlmCalloutService.cls       — Base LLM callout via Named Credential
├── PromptBuilder.cls           — Structured prompt assembly with context injection
├── LlmResponseParser.cls       — Typed response parsing and validation
└── AiOrchestrationService.cls  — Workflow coordinator for multi-step AI tasks
```

### Flow-Triggered AI Actions
`@InvocableMethod` surface exposing AI capability to Salesforce Flow — allowing declarative processes to invoke intelligent actions without code changes in the flow layer.

### Contextual Grounding Architecture
AI responses grounded in live Salesforce data — CRM context, record history, and org-specific business rules injected at inference time. Methodology is proprietary.

### AI-Augmented Development Workflow
Custom tooling that accelerates Salesforce development using AI assistance — code generation, schema analysis, deployment validation, and documentation synthesis. Built and operated as part of the Twiddle Box platform.

---

## Active Projects

| Project | Description | Status |
|---|---|---|
| Twiddle Box Platform | AI-augmented Salesforce dev platform | Active — private IP |
| Flow Intelligence Layer | AI-assisted Flow design and validation | In development |
| Schema Analyst | Natural language SOQL generation from schema | In development |

---

## Standards

- All LLM endpoints via Named Credentials — zero hardcoded URLs or keys
- Prompt inputs sanitized before injection — no raw user input passed to models
- Response validation before any DML — AI output never trusted without type-check
- Full request/response logging for auditability

---

## About

Built by **Jason Hogan** — Salesforce Solutions Architect & AI Engineer based in St. George, Utah.

- LinkedIn: [jason-hogan1](https://www.linkedin.com/in/jason-hogan1/)
- GitHub: [@jrhogan77](https://github.com/jrhogan77)
- Email: jrhogan.tbd@gmail.com
