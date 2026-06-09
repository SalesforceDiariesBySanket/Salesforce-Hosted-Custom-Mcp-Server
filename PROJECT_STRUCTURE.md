# Salesforce Hosted Custom MCP Server - Project Structure

```
Salesforce-Hosted-Custom-Mcp-Server/
├── README.md                           # Project overview and quick start
├── GETTING_STARTED.md                  # Detailed setup guide
├── DEVELOPMENT.md                      # Development guide for new tools
├── ARCHITECTURE.md                     # System architecture documentation
├── TROUBLESHOOTING.md                  # Common issues and solutions
├── LICENSE                             # MIT License
│
├── mcp-server-definitions/             # MCP Server metadata files
│   ├── README.md
│   ├── PublicInvocableApexMCP.mcpServerDefinition-meta.xml
│   ├── AuraEnabledApexMCP.mcpServerDefinition-meta.xml
│   ├── PromptTemplateMcpServer.mcpServerDefinition-meta.xml
│   ├── FlowMCP.mcpServerDefinition-meta.xml
│   ├── RestAPIMCP.mcpServerDefinition-meta.xml
│   ├── InvocableApex.mcpServerDefinition-meta.xml
│   ├── NamedQueryMcpService.mcpServerDefinition-meta.xml
│   ├── CaseCreationInvocableMcpService.mcpServerDefinition-meta.xml
│   ├── AIAgentMcpServer.mcpServerDefinition-meta.xml
│   ├── RestResourceApexMCP.mcpServerDefinition-meta.xml
│   ├── AuraEnbaledClassMcp.mcpServerDefinition-meta.xml
│   └── FlowAsMcpService.mcpServerDefinition-meta.xml
│
├── external-service-registrations/     # External Service Registration files
│   ├── README.md
│   ├── AccountAnalytics.externalServiceRegistration-meta.xml
│   ├── OpportunityMcpService.externalServiceRegistration-meta.xml
│   ├── OpportunityMcpServiceAuraEnbaled.externalServiceRegistration-meta.xml
│   ├── PromptTemplateMcpService.externalServiceRegistration-meta.xml
│   ├── GetCaseByCaseNumber.externalServiceRegistration-meta.xml
│   ├── GetOpportunitiesByAmount.externalServiceRegistration-meta.xml
│   ├── InvokeAgentAction.externalServiceRegistration-meta.xml
│   └── MyCustomAPI.externalServiceRegistration-meta.xml
│
└── apex-classes/                       # Apex service implementations
    ├── README.md
    ├── AccountAnalytics.cls            # Account analytics queries
    ├── OpportunityMcpService.cls       # High-value opportunity retrieval
    ├── OpportunityMcpServiceAuraEnbaled.cls  # AuraEnabled variant
    ├── PromptTemplateMcpService.cls    # Prompt template execution
    ├── CreateCaseAction.cls            # Case creation
    └── GetCaseDetails.cls              # Case detail retrieval
```

## File Descriptions

### Root Level
- **README.md** - Project overview, key concepts, and quick start
- **GETTING_STARTED.md** - Step-by-step deployment and usage guide
- **DEVELOPMENT.md** - Guide for creating new MCP tools
- **ARCHITECTURE.md** - System design and component interactions
- **TROUBLESHOOTING.md** - Common issues and solutions
- **LICENSE** - MIT License terms

### MCP Server Definitions
These files define which tools are available through each MCP server. They reference Apex classes and External Service Registrations.

### External Service Registrations
These files map Apex classes to OpenAPI schemas, enabling external systems to discover and call Salesforce services.

### Apex Classes
Implementation classes that contain the actual business logic for MCP tools.

## Key Patterns

### Account Analytics Pattern
- Multiple query modes for flexibility
- Bulk-safe List input/output
- Error handling and graceful degradation

### Opportunity Service Pattern
- @AuraEnabled for agent integration
- WITH USER_MODE for security
- Response DTOs for structured output

### Prompt Template Pattern
- Integration with GenAI Prompt Templates
- Record-grounded content generation
- Error messaging for template failures

### Case Creation Pattern
- Invocable action pattern
- Auto-assigned case numbering
- Bulk-safe implementation
