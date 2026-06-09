# Apex Classes

Core implementation classes for MCP tools.

## Key Classes

### AccountAnalytics.cls
Provides account analytics with multiple query modes:
- top_revenue: Largest accounts by annual revenue
- by_industry: Distribution by industry
- recent: Recently created accounts
- health_summary: Data completeness metrics

### OpportunityMcpService.cls
Retrieves high-value opportunities above a configurable threshold (default: $50,000).

### PromptTemplateMcpService.cls
Executes Prompt Builder templates for records and returns generated text.

### CreateCaseAction.cls
Creates new support cases with bulk-safe implementation.

## Best Practices

- Use WITH USER_MODE or WITH SECURITY_ENFORCED
- Implement proper error handling
- Write clear ApexDoc comments
- Create dedicated response classes
- Test all invocable methods
