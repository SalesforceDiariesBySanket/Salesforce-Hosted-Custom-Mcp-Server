# Architecture Overview

## System Components

### 1. MCP Server Definitions
Metadata files that define Model Context Protocol servers in Salesforce. Each server exposes specific tools that can be invoked by Agentforce agents or external MCP clients.

**Key Files:**
- `PublicInvocableApexMCP` - Exposes AccountAnalytics tool
- `AuraEnabledApexMCP` - Exposes OpportunityMcpService tool
- `PromptTemplateMcpServer` - Exposes prompt template tools
- `FlowMCP` - Exposes Flow-based tools

### 2. External Service Registrations
Define how Salesforce services are exposed via OpenAPI schemas. They map to Apex classes with specific annotations.

**Key Files:**
- `AccountAnalytics.externalServiceRegistration-meta.xml` - Maps to AccountAnalytics class
- `OpportunityMcpService.externalServiceRegistration-meta.xml` - Maps to OpportunityMcpService class
- `PromptTemplateMcpService.externalServiceRegistration-meta.xml` - Maps to PromptTemplateMcpService class

### 3. Apex Service Classes
Implementation classes that contain the actual business logic.

**Key Classes:**
- `AccountAnalytics` - Provides account analytics (top revenue, by industry, recent, health summary)
- `OpportunityMcpService` - Retrieves high-value opportunities
- `OpportunityMcpServiceAuraEnbaled` - AuraEnabled version for agent integration
- `PromptTemplateMcpService` - Executes prompt templates
- `CreateCaseAction` - Creates support cases
- `GetCaseDetails` - Retrieves case information

## Data Flow

```
Agentforce Agent / External MCP Client
        ↓
MCP Server Definition
        ↓
External Service Registration (OpenAPI Schema)
        ↓
Apex Service Class (@AuraEnabled or @InvocableMethod)
        ↓
Salesforce Data (Accounts, Opportunities, Cases)
```

## Security Architecture

1. **User Authentication**
   - MCP tools execute as the authenticated user
   - User's session credentials are validated

2. **Authorization**
   - Field-Level Security (FLS) enforced via WITH USER_MODE
   - Organization-Wide Defaults (OWD) and sharing rules applied
   - Permission sets and profiles restrict access

3. **Data Protection**
   - SOQL queries use WITH SECURITY_ENFORCED or WITH USER_MODE
   - Input validation on all parameters
   - Error messages don't expose sensitive data

## Deployment Architecture

### Standard Deployment
1. All components in a single package
2. Deployed via SFDX CLI
3. Metadata-driven configuration

### Production Best Practices
1. Use change sets or CI/CD pipelines
2. Deploy in lower environments first
3. Run full test suite
4. Verify MCP servers appear in Setup
5. Test tools in Agentforce agents

## Performance Considerations

1. **Query Optimization**
   - Use LIMIT clauses to cap result sets
   - Add indexes on frequently filtered fields
   - Use aggregate queries where appropriate

2. **Batch Processing**
   - Use bulk-safe patterns (@InvocableMethod with Lists)
   - Handle large datasets efficiently

3. **Caching**
   - Use @AuraEnabled(cacheable=true) where appropriate
   - Implement application-level caching for reference data

## Extension Points

### Adding New MCP Tools
1. Create an Apex class with @AuraEnabled method
2. Create an External Service Registration mapping
3. Create an MCP Server Definition exposing the tool
4. Deploy and test

### Adding New Services
1. Create Invocable Apex class with @InvocableMethod
2. Create test class with @isTest annotation
3. Deploy and validate in Setup

### Integrating Prompt Templates
1. Create GenAI Prompt Template
2. Reference in MCP Server Definition
3. Use PromptTemplateMcpService to execute
