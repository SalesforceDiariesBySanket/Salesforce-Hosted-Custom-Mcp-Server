/**
 * Exposes high-value Opportunity data to Agentforce agents and to a hosted
 * custom MCP server.
 *
 * The method below is annotated with @AuraEnabled, which is the contract a
 * hosted MCP custom server uses to surface an Apex method as an MCP tool.
 * The ApexDoc comment on the method becomes the tool's description, so write
 * it for the model that will read it — clear, specific, and action oriented.
 *
 * @see https://developer.salesforce.com/docs/ai/agentforce/guide/agent-auraenabled.html
 * @see https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/custom-servers.html
 */
public with sharing class OpportunityMcpServiceAuraEnbaled {
    // Default cutoff used when the caller does not supply a minimum amount.
    private static final Decimal DEFAULT_THRESHOLD = 50000;

    /**
     * Retrieves all Opportunities whose Amount is greater than a minimum
     * value (defaults to $50,000), ordered from the largest deal to the
     * smallest.
     *
     * Use this to answer questions like "show me the big deals" or
     * "which opportunities are worth more than 100k". Results respect the
     * running user's sharing and field-level security.
     *
     * @param minimumAmount The exclusive lower bound on Opportunity Amount.
     *        Pass null to use the default of 50000.
     * @return A list of high-value opportunities, largest Amount first.
     */
    @AuraEnabled
    public static List<HighValueOpportunity> getHighValueOpportunities(Decimal minimumAmount) {
        Decimal threshold = (minimumAmount == null) ? DEFAULT_THRESHOLD : minimumAmount;
        List<HighValueOpportunity> results = new List<HighValueOpportunity>();

        // WITH USER_MODE enforces the running user's FLS and sharing rules —
        // important when the method is reachable from an agent / MCP tool.
        for (Opportunity opp : [
            SELECT Id, Name, Amount, StageName, CloseDate, Account.Name
            FROM Opportunity
            WHERE Amount > :threshold
            WITH USER_MODE
            ORDER BY Amount DESC
        ]) {
            HighValueOpportunity row = new HighValueOpportunity();
            row.opportunityId = opp.Id;
            row.name = opp.Name;
            row.amount = opp.Amount;
            row.stageName = opp.StageName;
            row.closeDate = opp.CloseDate;
            row.accountName = (opp.Account == null) ? null : opp.Account.Name;
            results.add(row);
        }
        return results;
    }

    /**
     * Lightweight DTO returned to the agent / MCP client. Every field that
     * should be visible to the caller must be annotated with @AuraEnabled.
     */
    public class HighValueOpportunity {
        @AuraEnabled public Id opportunityId;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String stageName;
        @AuraEnabled public Date closeDate;
        @AuraEnabled public String accountName;
    }
}