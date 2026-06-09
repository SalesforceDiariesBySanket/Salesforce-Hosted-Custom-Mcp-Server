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
            lines.add(i + '. ' + a.Name +
                ' — $' + formatNum(a.AnnualRevenue) +
                ' [' + nvl(a.Industry, 'n/a') + ']' +
                (a.NumberOfEmployees != null ? ' • ' + a.NumberOfEmployees + ' emp' : ''));
            i++;
        }
        return 'Top ' + accs.size() + ' Accounts by Annual Revenue:\n' + String.join(lines, '\n');
    }

    private static String byIndustry(String industryFilter, Response resp) {
        if (String.isNotBlank(industryFilter)) {
            String filt = industryFilter.trim();
            List<Account> accs = [
                SELECT Name, AnnualRevenue, NumberOfEmployees
                FROM Account
                WHERE Industry = :filt
                ORDER BY AnnualRevenue DESC NULLS LAST
                LIMIT 25
            ];
            resp.total = accs.size();
            if (accs.isEmpty()) return 'No Accounts found in industry "' + filt + '".';
            Decimal totalRev = 0;
            List<String> lines = new List<String>();
            Integer i = 1;
            for (Account a : accs) {
                if (a.AnnualRevenue != null) totalRev += a.AnnualRevenue;
                lines.add(i + '. ' + a.Name + ' — $' + formatNum(a.AnnualRevenue));
                i++;
            }
            return 'Industry "' + filt + '": ' + accs.size() + ' Accounts, combined revenue $' + formatNum(totalRev) + '\n' + String.join(lines, '\n');
        }
        AggregateResult[] groups = [
            SELECT Industry ind, COUNT(Id) cnt, SUM(AnnualRevenue) rev
            FROM Account
            GROUP BY Industry
            ORDER BY COUNT(Id) DESC
            LIMIT 25
        ];
        resp.total = groups.size();
        if (groups.isEmpty()) return 'No Accounts found.';
        List<String> lines = new List<String>();
        Integer i = 1;
        for (AggregateResult ag : groups) {
            String ind = (String) ag.get('ind');
            Integer cnt = (Integer) ag.get('cnt');
            Object revObj = ag.get('rev');
            Decimal rev = revObj == null ? 0 : (Decimal) revObj;
            lines.add(i + '. ' + nvl(ind, '(no industry)') + ' — ' + cnt + ' accts, $' + formatNum(rev));
            i++;
        }
        return 'Account distribution by industry:\n' + String.join(lines, '\n');
    }

    private static String recent(Integer topN, Response resp) {
        List<Account> accs = [
            SELECT Name, Industry, CreatedDate, AnnualRevenue
            FROM Account
            ORDER BY CreatedDate DESC
            LIMIT :topN
        ];
        resp.total = accs.size();
        if (accs.isEmpty()) return 'No Accounts found.';
        List<String> lines = new List<String>();
        Integer i = 1;
        for (Account a : accs) {
            lines.add(i + '. ' + a.Name + ' — ' + nvl(a.Industry, 'n/a') + ' • created ' + a.CreatedDate.format('yyyy-MM-dd'));
            i++;
        }
        return 'Most recently created Accounts:\n' + String.join(lines, '\n');
    }

    private static String healthSummary(Response resp) {
        Integer total = [SELECT COUNT() FROM Account];
        Integer withRev = [SELECT COUNT() FROM Account WHERE AnnualRevenue != NULL];
        Integer withInd = [SELECT COUNT() FROM Account WHERE Industry != NULL];
        Integer withEmp = [SELECT COUNT() FROM Account WHERE NumberOfEmployees != NULL];
        AggregateResult agg = [SELECT SUM(AnnualRevenue) tot, AVG(AnnualRevenue) avg FROM Account];
        Decimal totRev = agg.get('tot') == null ? 0 : (Decimal) agg.get('tot');
        Decimal avgRev = agg.get('avg') == null ? 0 : (Decimal) agg.get('avg');
        resp.total = total;
        return 'Account health:\n' +
               '  Total accounts: ' + total + '\n' +
               '  With AnnualRevenue: ' + withRev + ' (' + pct(withRev, total) + '%)\n' +
               '  With Industry: ' + withInd + ' (' + pct(withInd, total) + '%)\n' +
               '  With NumberOfEmployees: ' + withEmp + ' (' + pct(withEmp, total) + '%)\n' +
               '  Total revenue: $' + formatNum(totRev) + '\n' +
               '  Average revenue: $' + formatNum(avgRev);
    }

    private static String nvl(String s, String fallback) {
        return String.isBlank(s) ? fallback : s;
    }

    private static String formatNum(Decimal d) {
        if (d == null) return '0';
        return d.setScale(0).format();
    }

    private static Integer pct(Integer part, Integer total) {
        if (total == null || total == 0) return 0;
        return (Integer) ((Decimal.valueOf(part) / Decimal.valueOf(total)) * 100).round();
    }
}