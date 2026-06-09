# Development Guide

## Setting Up Development Environment

### Prerequisites
- Salesforce Developer Edition org or sandbox
- SFDX CLI installed
- Git for version control
- A code editor (VS Code recommended)

### Initial Setup

```bash
# Clone repository
git clone https://github.com/SalesforceDiariesBySanket/Salesforce-Hosted-Custom-Mcp-Server.git
cd Salesforce-Hosted-Custom-Mcp-Server

# Authenticate with org
sfdx auth:web:login -a development

# Deploy source
sfdx force:source:deploy -p . -u development
```

## Creating New MCP Tools

### Step 1: Create Apex Class

Create a new Apex class with @AuraEnabled method:

```apex
public with sharing class MyNewMcpService {
    @AuraEnabled
    public static List<Result> getMyData(String parameter) {
        List<Result> results = new List<Result>();
        
        for (MyObject__c obj : [SELECT Id, Name FROM MyObject__c WHERE Status = :parameter WITH USER_MODE]) {
            Result r = new Result();
            r.id = obj.Id;
            r.name = obj.Name;
            results.add(r);
        }
        
        return results;
    }
    
    public class Result {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
    }
}
```

### Step 2: Create External Service Registration

Create file: `external-service-registrations/MyNewMcpService.externalServiceRegistration-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ExternalServiceRegistration xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>My custom MCP service for getting data</description>
    <label>MyNewMcpService</label>
    <operations>
        <active>true</active>
        <name>getmydata</name>
    </operations>
    <registrationProviderAsset>MyNewMcpService</registrationProviderAsset>
    <registrationProviderType>AuraEnabled</registrationProviderType>
    <status>Complete</status>
    <systemVersion>3</systemVersion>
</ExternalServiceRegistration>
```

### Step 3: Create MCP Server Definition

Create file: `mcp-server-definitions/MyNewMcpServer.mcpServerDefinition-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<McpServerDefinition xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>My new MCP server for custom data</description>
    <masterLabel>MyNewMcpServer</masterLabel>
    <tools>
        <apiDefinition>
            <apiIdentifier>ae:MyNewMcpService</apiIdentifier>
            <apiSource>API_CATALOG</apiSource>
            <operation>getMyData</operation>
        </apiDefinition>
        <descriptionOverride>Retrieves custom data based on specified parameters</descriptionOverride>
        <toolName>getMyDataMyNewMcpService</toolName>
        <toolTitle>getMyData</toolTitle>
    </tools>
</McpServerDefinition>
```

### Step 4: Deploy and Test

```bash
# Deploy the new components
sfdx force:source:deploy -p apex-classes,external-service-registrations,mcp-server-definitions -u development

# Run Apex tests
sfdx force:apex:test:run -u development
```

## Testing Best Practices

### Unit Testing Apex Classes

```apex
@isTest
private class MyNewMcpServiceTest {
    @isTest
    static void testGetMyData() {
        // Setup
        MyObject__c obj = new MyObject__c(Name = 'Test', Status = 'Active');
        insert obj;
        
        // Execute
        List<MyNewMcpService.Result> results = MyNewMcpService.getMyData('Active');
        
        // Assert
        Assert.areEqual(1, results.size());
        Assert.areEqual('Test', results[0].name);
    }
}
```

### Testing in Agentforce

1. Create test agent
2. Add tool from your MCP server
3. Test in agent simulator
4. Check debug logs for errors
5. Iterate and refine

## Code Standards

### ApexDoc Comments
Write clear ApexDoc comments - they become tool descriptions:

```apex
/**
 * Retrieves high-value opportunities above a configurable threshold.
 * Use this to answer questions like "show me deals over $100K" or
 * "what opportunities are worth more than $50,000?"
 * 
 * @param minimumAmount The exclusive lower bound on Opportunity Amount.
 *        Pass null to use the default of $50,000.
 * @return A list of opportunities, largest Amount first.
 */
@AuraEnabled
public static List<HighValueOpportunity> getHighValueOpportunities(Decimal minimumAmount) {
    // Implementation
}
```

### Naming Conventions

- Apex Classes: PascalCase (e.g., `OpportunityMcpService`)
- Methods: camelCase (e.g., `getHighValueOpportunities`)
- MCP Tools: camelCase (e.g., `getHighValueOpportunities`)
- Variables: camelCase (e.g., `minimumAmount`)

### Security Best Practices

1. Always use WITH USER_MODE or WITH SECURITY_ENFORCED
2. Validate all input parameters
3. Avoid exposing sensitive error messages
4. Use appropriate sharing keywords
5. Implement fine-grained permission checks when needed

## Source Deployment

```bash
# Deploy specific components
sfdx force:source:deploy -p apex-classes/MyNewMcpService.cls -u development

# Deploy entire directory
sfdx force:source:deploy -p apex-classes -u development

# Deploy and run tests
sfdx force:source:deploy -p . -u development -l RunLocalTests
```

## Continuous Integration

Example GitHub Actions workflow:

```yaml
name: Deploy to Salesforce
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install SFDX
        uses: salesforcecli/setup-sfdx@v1
      - name: Authenticate
        run: echo ${{ secrets.SFDX_AUTH }} | sfdx auth:sfdxurl:store
      - name: Deploy
        run: sfdx force:source:deploy -p . -u production
```
