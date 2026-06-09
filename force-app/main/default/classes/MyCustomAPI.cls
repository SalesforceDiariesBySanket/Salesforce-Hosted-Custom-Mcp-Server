@RestResource(urlMapping='/MyCustomAPI/*')
global with sharing class MyCustomAPI {

    // GET /services/apexrest/MyCustomAPI/
    // Optional query param: ?minAmount=50000  (defaults to 50,000 when omitted)
    @HttpGet
    global static List<OpportunityInfo> doGet() {
        String minParam = RestContext.request.params.get('minAmount');
        Decimal minAmount = String.isNotBlank(minParam)
            ? Decimal.valueOf(minParam)   // assumes a numeric value
            : 50000;

        List<OpportunityInfo> results = new List<OpportunityInfo>();
        for (Opportunity opp : [
            SELECT Id, Name, Amount, StageName, CloseDate
            FROM Opportunity
            WHERE Amount > :minAmount
            ORDER BY Amount DESC
            LIMIT 200
        ]) {
            results.add(new OpportunityInfo(opp));
        }
        return results;
    }

    // Concrete return type (not Object) so the OpenAPI generator can describe the response shape
    global class OpportunityInfo {
        global String  opportunityId;
        global String  name;
        global Decimal amount;
        global String  stageName;
        global Date    closeDate;

        global OpportunityInfo(Opportunity opp) {
            this.opportunityId = opp.Id;
            this.name          = opp.Name;
            this.amount        = opp.Amount;
            this.stageName     = opp.StageName;
            this.closeDate     = opp.CloseDate;
        }
    }
}