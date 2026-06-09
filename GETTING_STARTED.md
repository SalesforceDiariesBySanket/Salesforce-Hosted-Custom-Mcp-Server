# Getting Started with Salesforce Hosted Custom MCP Server

## Prerequisites

- Salesforce org (Spring 25 or later)
- SFDX CLI installed
- Necessary permissions in your org

## Deployment Steps

### 1. Clone Repository

```bash
git clone https://github.com/SalesforceDiariesBySanket/Salesforce-Hosted-Custom-Mcp-Server.git
```

### 2. Authenticate

```bash
sfdx auth:web:login -a myorg
```

### 3. Deploy Components

```bash
sfdx force:source:deploy -p . -u myorg
```

### 4. Verify in Org

Navigate to Setup > Integrations > Model Context Protocol Servers to verify deployment.

## Usage

Each MCP server exposes specific tools that can be used in Agentforce agents and external MCP clients.

## Troubleshooting

- Verify MCP Server Definition is active
- Check External Service Registration status
- Ensure Apex class has @AuraEnabled or is in API_CATALOG
- Review debug logs for errors

## Security

All methods enforce user security:
- FLS (Field-Level Security)
- Sharing rules
- Organization-wide defaults

Always use WITH USER_MODE or WITH SECURITY_ENFORCED in SOQL queries.
