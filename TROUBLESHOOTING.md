# Troubleshooting Guide

## Common Issues

### 1. MCP Server Not Appearing in Setup

**Symptom:** MCP Server Definition exists but doesn't show up in Setup > Integrations > Model Context Protocol Servers

**Solutions:**
- Verify MCP Server Definition metadata file is deployed
- Check file naming follows pattern: `*.mcpServerDefinition-meta.xml`
- Ensure API version is correct (Spring 25 or later)
- Check org permissions to create MCP servers

### 2. Tool Not Available in Agent

**Symptom:** MCP Server appears but specific tool is not available

**Solutions:**
- Verify External Service Registration status is "Complete"
- Check that apiIdentifier matches Apex class name or API Catalog entry
- Verify Apex class has @AuraEnabled annotation
- Check user has access to the Apex class
- Review debug logs for registration errors

### 3. Tool Fails During Execution

**Symptom:** Tool appears in agent but fails when invoked

**Solutions:**

**SOQL Query Issues:**
```apex
// Bad - doesn't enforce security
List<Account> accs = [SELECT Name FROM Account];

// Good - enforces user's FLS and sharing
List<Account> accs = [SELECT Name FROM Account WITH USER_MODE];
```

**Check Debug Logs:**
```bash
sfdx force:apex:log:tail -u myorg
```

**Verify Permissions:**
- User has Read access to objects in query
- User has access to fields being queried
- User's sharing rules allow record access

### 4. Schema Validation Errors

**Symptom:** External Service Registration fails with schema validation error

**Solutions:**
- Verify OpenAPI schema is valid YAML/JSON
- Check parameter names match Apex method signature
- Ensure response types are properly defined
- Review External Services schema editor

### 5. Prompt Template Execution Fails

**Symptom:** PromptTemplateMcpService returns error message

**Solutions:**
- Verify prompt template exists and is published
- Check template name matches exactly (case-sensitive)
- Verify record ID is valid and exists
- Check user has "Execute Prompt Templates" permission
- Review prompt template definition for syntax errors

## Debug Techniques

### 1. Using Execute Anonymous

```apex
// Test AccountAnalytics
AccountAnalytics.Request req = new AccountAnalytics.Request();
req.mode = 'top_revenue';
req.top_n = 5;
List<AccountAnalytics.Response> results = AccountAnalytics.invoke(new List<AccountAnalytics.Request>{req});
System.debug(results[0].summary);
```

### 2. Checking Debug Logs

```bash
# Tail logs in real-time
sfdx force:apex:log:tail -u myorg

# Get specific log
sfdx force:apex:log:get -i <log_id> -u myorg
```

### 3. Verifying Apex Class Access

```apex
List<ApexClass> classes = [SELECT Name, ApiVersion FROM ApexClass WHERE Name = 'OpportunityMcpService'];
System.debug(classes);
```

### 4. Testing SOQL with User Mode

```apex
try {
    List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WITH USER_MODE LIMIT 10];
    System.debug('Success: ' + opps.size());
} catch (QueryException e) {
    System.debug('FLS or sharing violation: ' + e.getMessage());
}
```

## Performance Diagnostics

### Slow Query Performance

1. Check query complexity
2. Add indexes to frequently filtered fields
3. Use LIMIT to reduce results
4. Avoid complex joins

### High API Usage

1. Reduce query frequency
2. Implement caching
3. Batch operations where possible
4. Monitor API call limits

## Getting Help

1. Check Salesforce documentation
2. Review Apex logs for specific error messages
3. Test components individually
4. Consult Salesforce communities
5. Contact Salesforce support for platform issues
