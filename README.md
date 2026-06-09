# Salesforce Hosted Custom MCP Server

A reference SFDX project demonstrating every supported pattern for building a **Salesforce-hosted custom MCP (Model Context Protocol) server**. Each `McpServerDefinition` shows a different way to expose Salesforce functionality — Apex classes, Flows, Named Queries, and Prompt Templates — as tools that any MCP-compatible client (Claude Desktop, OpenAI, Cursor, etc.) can discover and call.

> Blog series: [Salesforce Diaries by Sanket](https://www.salesforcediaries.com)

---

## What is a Salesforce Hosted MCP Server?

Salesforce lets you publish a standard [MCP](https://modelcontextprotocol.io) endpoint directly from your org — no middleware, no Lambda, no Node server. You define what tools are exposed through `McpServerDefinition` metadata, and Salesforce handles the authentication, schema generation, and HTTP transport. An external AI agent connects to `https://<your-org>.my.salesforce.com/services/mcp/v1/<serverName>` using OAuth and gets a live, permissioned connection to your data.

---

## Project Structure

```
force-app/main/default/
├── mcpServerDefinitions/          # 14 MCP server definitions (one per pattern)
├── externalServiceRegistrations/  # OpenAPI registrations for each Apex endpoint
├── flows/
│   └── Get_Account_By_Name.flow-meta.xml
├── classes/                       # 7 Apex classes backing the MCP tools
└── genAiPromptTemplates/          # 4 Prompt Builder templates exposed as MCP prompts
sfdx-project.json
```

---

## MCP Server Definitions

Each definition registers one MCP server in your org and declares which tools and prompts it exposes.

### 1. `FlowAsMcpService` — Flow as MCP Tool
Exposes the `Get_Account_By_Name` AutoLaunchedFlow as a tool.  
**Pattern:** `fa:flow-<FlowApiName>` (Flow via API Catalog)

```
Tool → Get_Account_By_Name
```

### 2. `FlowMCP` — Flow MCP (variant)
A second server exposing the same `Get_Account_By_Name` flow, demonstrating that multiple servers can surface the same underlying action.  
**Pattern:** `fa:flow-<FlowApiName>`

### 3. `InvocableApex` — Invocable Apex + Prompt Templates
Combines an `@InvocableMethod` tool with three Prompt Builder prompts in one server.  
**Pattern:** `aa:apex-<ClassName>` + `promptTemplateName`

```
Tool   → CreateCaseAction
Prompt → Draft_IT_Troubleshooting
Prompt → Get_Event_Info
Prompt → Case_Research_from_Web
```

### 4. `AuraEnabledApexMCP` — @AuraEnabled Method
Exposes the `getHighValueOpportunities` method from `OpportunityMcpService` (annotated `@AuraEnabled`).  
**Pattern:** `ae:<ClassName>`

```
Tool → getHighValueOpportunities (OpportunityMcpService)
```

### 5. `AuraEnbaledClassMcp` — @AuraEnabled (alternate class)
Same tool pattern as above but backed by `OpportunityMcpServiceAuraEnbaled`.  
**Pattern:** `ae:<ClassName>`

```
Tool → getHighValueOpportunities (OpportunityMcpServiceAuraEnbaled)
```

### 6. `PublicInvocableApexMCP` — @AuraEnabled for Account Analytics
Exposes `AccountAnalytics.invoke` — a multi-mode analytics tool that runs aggregations over Account records.  
**Pattern:** `ae:<ClassName>`

```
Tool → invoke (AccountAnalytics)
```

### 7. `AIAgentMcpServer` — Talk to an Agentforce Agent
Lets an MCP client send a natural-language message to an Agentforce agent and get its reply. Supports multi-turn sessions via `sessionId`.  
**Pattern:** `ae:<ClassName>`

```
Tool → askAgent (InvokeAgentAction)
```

### 8. `CaseCreationInvocableMcpService` — Create Cases via Invocable
Exposes `CreateCaseAction` as an MCP tool so external agents can open support cases directly.  
**Pattern:** `aa:apex-<ClassName>`

```
Tool → CreateCaseAction
```

### 9. `NamedQueryMcpService` — Named Query
Exposes a Named Query (`GetOpportunitiesByAmount`) defined in the org as a zero-code MCP tool.  
**Pattern:** `nq:<QueryApiName>`

```
Tool → GetOpportunitiesByAmount
```

### 10. `PromptTemplateMcpServer` — Named Query + Prompt Template
Mixes a Named Query tool with a Prompt Builder prompt in one server.  
**Pattern:** `nq:<QueryApiName>` + `promptTemplateName`

```
Tool   → GetOpportunitiesByAmount
Prompt → Research_on_Case_subject
```

### 11. `RestResourceApexMCP` — @RestResource Apex
Exposes `MyCustomAPI` — a `@RestResource`-annotated class — as an MCP tool.  
**Pattern:** `ar:<ClassName>`

```
Tool → doGet (MyCustomAPI)
```

### 12. `PromptMcpServer` — Prompt-Only Server
A server that exposes only a Prompt Builder template, with no tool.  
**Pattern:** `promptTemplateName`

```
Prompt → Case_Research_from_Web
```

### 13. `AgentforceMCP` — Agentforce Agent Shell
Skeleton server demonstrating how to declare an Agentforce-connected MCP server.

### 14. `RestAPIMCP` — REST API Shell
Skeleton server for REST-based MCP tool patterns.

---

## Apex Classes

| Class | Annotation | What it does |
|---|---|---|
| `OpportunityMcpService` | `@AuraEnabled` | Returns Opportunities with `Amount > threshold` (default $50k), ordered largest first. Enforces sharing and FLS via `WITH USER_MODE`. |
| `OpportunityMcpServiceAuraEnbaled` | `@AuraEnabled` | Variant of the above, demonstrating the same pattern in a separate class. |
| `AccountAnalytics` | `@InvocableMethod` | Runs one of four aggregation modes over Account: `top_revenue`, `by_industry`, `recent`, or `health_summary`. Returns a human-readable summary string. |
| `CreateCaseAction` | `@InvocableMethod` | Creates a Salesforce Case from a subject line. Bulk-safe; re-queries to return the auto-assigned Case Number. |
| `InvokeAgentAction` | `@InvocableMethod` | Sends a natural-language message to any active Agentforce agent via `generateAiAgentResponse`. Returns the agent's reply and a `sessionId` for multi-turn conversations. Default agent: `Case_CRUD_Agent`. |
| `MyCustomAPI` | `@RestResource` | `GET /services/apexrest/MyCustomAPI/` — returns Opportunities above a configurable `minAmount` threshold. Used by `RestResourceApexMCP`. |
| `PromptTemplateMcpService` | `@AuraEnabled` | Runs a named Prompt Builder template against a record using `ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate`. Returns the generated text. |

---

## Flow

### `Get_Account_By_Name`
**Type:** AutoLaunchedFlow  
**Input:** `AccountName` (String)  
**Output:** `AccountDetails` (Account SObject)

Queries the first Account whose `Name` equals the input string and returns the full record. Used by `FlowAsMcpService` and `FlowMCP`.

---

## Prompt Templates (`genAiPromptTemplates`)

These Prompt Builder templates are registered on MCP servers as **prompts** — the MCP equivalent of a reusable, parameterised instruction that a client can invoke by name.

| Template | Referenced by |
|---|---|
| `Draft_IT_Troubleshooting` | `InvocableApex` |
| `Get_Event_Info` | `InvocableApex` |
| `Case_Research_from_Web` | `InvocableApex`, `PromptMcpServer` |
| `Research_on_Case_subject` | `PromptTemplateMcpServer` |

---

## External Service Registrations

OpenAPI-based registrations that describe the shape of each Apex endpoint so Salesforce can generate the tool schemas for the MCP catalog.

| Registration | Apex class |
|---|---|
| `AccountAnalytics` | `AccountAnalytics` |
| `GetCaseByCaseNumber` | Case lookup endpoint |
| `GetOpportunitiesByAmount` | Named Query |
| `InvokeAgentAction` | `InvokeAgentAction` |
| `MyCustomAPI` | `MyCustomAPI` |
| `OpportunityMcpService` | `OpportunityMcpService` |
| `OpportunityMcpServiceAuraEnbaled` | `OpportunityMcpServiceAuraEnbaled` |
| `PromptTemplateMcpService` | `PromptTemplateMcpService` |

---

## Deploy

### Prerequisites
- Salesforce CLI (`sf`) v2+
- API version 66.0 org (Summer '25+)
- "Salesforce Hosted MCP Servers" feature enabled in your org

### Deploy all metadata
```bash
sf project deploy start --source-dir force-app
```

### Deploy a specific server only
```bash
sf project deploy start --metadata McpServerDefinition:FlowAsMcpService
```

### Connect a client (example: Claude Desktop)
Add this to your `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "salesforce-flow": {
      "url": "https://<your-org>.my.salesforce.com/services/mcp/v1/FlowAsMcpService",
      "transport": "http",
      "headers": {
        "Authorization": "Bearer <access_token>"
      }
    }
  }
}
```

---

## References

- [Salesforce Hosted MCP Servers — Developer Guide](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/custom-servers.html)
- [AuraEnabled MCP pattern](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-auraenabled.html)
- [Model Context Protocol spec](https://modelcontextprotocol.io)
