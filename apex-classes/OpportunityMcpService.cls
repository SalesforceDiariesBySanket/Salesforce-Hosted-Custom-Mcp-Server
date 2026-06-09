public with sharing class OpportunityMcpService {

    private static final Decimal DEFAULT_THRESHOLD = 50000;

    @AuraEnabled
    public static List<HighValueOpportunity> getHighValueOpportunities(Decimal minimumAmount) {
        Decimal threshold = (minimumAmount == null) ? DEFAULT_THRESHOLD : minimumAmount;
        List<HighValueOpportunity> results = new List<HighValueOpportunity>();

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

    public class HighValueOpportunity {
        @AuraEnabled public Id opportunityId;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String stageName;
        @AuraEnabled public Date closeDate;
        @AuraEnabled public String accountName;
    }
}