public with sharing class AccountAnalytics {

    public class Request {
        @InvocableVariable(label='Mode' required=true description='top_revenue | by_industry | recent | health_summary')
        public String mode;

        @InvocableVariable(label='Top N' description='Used by top_revenue (default 10) and recent (default 10)')
        public Integer top_n;

        @InvocableVariable(label='Industry Filter' description='Optional, used only by by_industry to drill into one segment')
        public String industry;
    }

    public class Response {
        @InvocableVariable(label='Summary')
        public String summary;

        @InvocableVariable(label='Mode')
        public String mode;

        @InvocableVariable(label='Total Records Considered')
        public Integer total;
    }

    @InvocableMethod(label='Account Analytics' 
    description='Aggregations over Account: top by revenue, by industry, recent, or overall health summary.'
    category='Agentforce')
    public static List<Response> invoke(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            Response resp = new Response();
            resp.mode = r.mode;
            try {
                String mode = String.isBlank(r.mode) ? 'health_summary' : r.mode.toLowerCase().trim();
                Integer topN = (r.top_n == null || r.top_n <= 0) ? 10 : Math.min(r.top_n, 50);
                if (mode == 'top_revenue') {
                    resp.summary = topRevenue(topN, resp);
                } else if (mode == 'by_industry') {
                    resp.summary = byIndustry(r.industry, resp);
                } else if (mode == 'recent') {
                    resp.summary = recent(topN, resp);
                } else {
                    resp.summary = healthSummary(resp);
                }
            } catch (Exception e) {
                resp.summary = 'Account analytics failed: ' + e.getMessage();
            }
            out.add(resp);
        }
        return out;
    }

    private static String topRevenue(Integer topN, Response resp) {
        List<Account> accs = [
            SELECT Name, Industry, AnnualRevenue, NumberOfEmployees, Type
            FROM Account
            WHERE AnnualRevenue != NULL
            ORDER BY AnnualRevenue DESC NULLS LAST
            LIMIT :topN
        ];
        resp.total = accs.size();
        if (accs.isEmpty()) return 'No Accounts with AnnualRevenue set were found.';
        List<String> lines = new List<String>();
        Integer i = 1;
        for (Account a : accs) {
            lines.add(i + '. ' + a.Name + ' — $' + formatNum(a.AnnualRevenue) + ' [' + nvl(a.Industry, 'n/a') + ']');
            i++;
        }
        return 'Top ' + accs.size() + ' Accounts by Annual Revenue: ' + String.join(lines, ', ');
    }

    private static String byIndustry(String industryFilter, Response resp) {
        Map<String, Integer> byInd = new Map<String, Integer>();
        for (AggregateResult ar : [SELECT Industry, COUNT(Id) cnt FROM Account WHERE Industry != NULL GROUP BY Industry ORDER BY COUNT(Id) DESC]) {
            byInd.put((String) ar.get('Industry'), (Integer) ar.get('cnt'));
        }
        resp.total = byInd.size();
        return 'Found ' + byInd.size() + ' industries.';
    }

    private static String recent(Integer topN, Response resp) {
        List<Account> accs = [SELECT Name, Industry, CreatedDate FROM Account ORDER BY CreatedDate DESC LIMIT :topN];
        resp.total = accs.size();
        return 'Found ' + accs.size() + ' recent accounts.';
    }

    private static String healthSummary(Response resp) {
        AggregateResult ar = [SELECT COUNT(Id) total FROM Account][0];
        Long total = (Long) ar.get('total');
        resp.total = (Integer) total;
        return 'Total accounts: ' + total;
    }

    private static String nvl(String val, String def) {
        return String.isBlank(val) ? def : val;
    }

    private static String formatNum(Decimal val) {
        if (val == null) return '0';
        if (val >= 1000000) return (val / 1000000).setScale(1) + 'M';
        if (val >= 1000) return (val / 1000).setScale(1) + 'K';
        return val.toPlainString();
    }
}