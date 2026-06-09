# Salesforce Hosted Custom MCP Server

## Overview

This repository contains Salesforce Model Context Protocol (MCP) Server definitions, External Service Registrations, and related Apex Classes for building and deploying custom MCP servers on Salesforce.

## Directory Structure

```
├── apex-classes/                    # Core Apex implementations
├── external-service-registrations/  # External Service Registrations
├── mcp-server-definitions/          # MCP Server metadata files
├── config/                          # SFDX configuration
├── manifest/                        # Deployment manifest
├── force-app/                       # Force-app source directory
├── sfdx-project.json               # SFDX project configuration
├── package.json                     # NPM dependencies
└── README.md                        # This file
```

## Key Components

### MCP Server Definitions
- **PublicInvocableApexMCP** - Account Analytics queries
- **AuraEnabledApexMCP** - AuraEnabled Apex methods
- **PromptTemplateMcpServer** - Prompt template integration
- **FlowMCP** - Flow-based services
- **RestAPIMCP** - Custom REST APIs
- **InvocableApex** - Invocable Apex actions
- **NamedQueryMcpService** - Named Query API
- **CaseCreationInvocableMcpService** - Case creation
- **AIAgentMcpServer** - Agentforce agent invocation
- **RestResourceApexMCP** - REST resource methods

### Apex Classes
- **AccountAnalytics.cls** - Account analytics (top revenue, by industry, recent, health summary)
- **OpportunityMcpService.cls** - High-value opportunity queries
- **OpportunityMcpServiceAuraEnbaled.cls** - AuraEnabled variant
- **PromptTemplateMcpService.cls** - Prompt template execution
- **CreateCaseAction.cls** - Case creation invocable action
- **GetCaseDetails.cls** - Case detail retrieval

### External Service Registrations
- Expose Apex methods as OpenAPI services
- Support AuraEnabled, NamedQuery, and REST types
- Auto-generate schemas from Apex annotations

## Deployment

### Prerequisites
- Salesforce CLI (SFDX) installed
- Org authentication configured
- Spring 25 or later (for full MCP support)

### Deploy to Org

```bash
# Authenticate with your org
sfdx auth:web:login -a myorg

# Deploy source code
sfdx force:source:deploy -p force-app -u myorg

# Run tests
sfdx force:apex:test:run -u myorg
```

### Verify Deployment

1. Navigate to **Setup > Integrations > Model Context Protocol Servers**
2. Verify all MCP servers are listed
3. Check **Setup > Integrations > External Service Registrations** for service definitions

## Development

### Creating New MCP Tools

1. Create an Apex class with @AuraEnabled method:
```apex
@AuraEnabled
public static List<Result> getMyData(String parameter) {
    // Implementation
}
```

2. Create External Service Registration mapping
3. Create MCP Server Definition exposing the tool
4. Deploy and test

### Code Standards

- Use WITH USER_MODE or WITH SECURITY_ENFORCED in SOQL queries
- Write clear ApexDoc comments (become tool descriptions)
- Create dedicated response DTOs
- Implement comprehensive error handling
- Write unit tests for all methods

## Security

- Methods execute as authenticated user
- Field-Level Security (FLS) enforced
- Organization-Wide Defaults (OWD) and sharing rules applied
- Input validation on all parameters
- Error messages don't expose sensitive data

## Resources

- [Salesforce MCP Documentation](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/)
- [Agentforce Developer Guide](https://developer.salesforce.com/docs/ai/agentforce/)
- [External Service Registrations](https://developer.salesforce.com/docs/platforms/Connect/concepts/external-service-registrations.htm)
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)

## Author

Salesforce Diaries by Sanket

## License

MIT License - See LICENSE file for details
