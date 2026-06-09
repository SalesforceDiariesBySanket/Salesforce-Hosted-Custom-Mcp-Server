/**
 * @description  Invocable Action that creates a Salesforce support Case.
 *
 *               Exposed as a custom MCP (Model Context Protocol) tool through a
 *               Salesforce Hosted MCP custom server, so an external agent — for
 *               example an OpenAI Responses API call — can create a case on demand.
 *
 *               Bulk-safe: accepts a list of requests and returns exactly one
 *               Result per request, in the same order.
 *
 *               Executes as the authenticated MCP user, so that user's profile,
 *               field-level security, sharing rules, and validation rules apply.
 *
 * @group        MCP Tools
 */
global with sharing class CreateCaseAction {

    /**
     * @description Input for the tool. Each Request creates exactly one Case.
     */
    global class Request {
        @InvocableVariable(
            label='Subject'
            description='Concise, human-readable summary of the issue, used as the Case subject line (e.g. "Login page returns a 500 error"). Required; max 255 characters.'
            required=true)
        global String subject;
    }

    /**
     * @description Output returned for each created Case.
     */
    global class Result {
        @InvocableVariable(
            label='Case ID'
            description='18-character Salesforce record Id of the newly created Case (e.g. 500XX0000004Cyz).')
        global Id caseId;

        @InvocableVariable(
            label='Case Number'
            description='Auto-generated, human-readable Case Number (e.g. 00001045). Use this when referring to the case in user-facing messages.')
        global String caseNumber;
    }

    /**
     * @description Creates one Case per request from the supplied subject, then
     *              re-queries to return each new Case's auto-assigned Case Number.
     * @param  requests  one Request per Case to create (bulk-safe)
     * @return one Result per input request, in the same order
     */
    @InvocableMethod(
        label='Create Case'
        description='Creates a new Salesforce support Case from a subject line and returns its record Id and Case Number. Use when a customer or user reports a new issue, question, or request that should be logged and tracked. Does not update or escalate existing cases.'
        category='Case Management')
    global static List<Result> createCases(List<Request> requests) {
        List<Case> cases = new List<Case>();
        for (Request req : requests) {
            cases.add(new Case(Subject = req.subject));
        }
        insert cases;

        // CaseNumber is auto-assigned on insert and is not populated on the
        // in-memory records, so re-query to read it back.
        Map<Id, Case> saved = new Map<Id, Case>(
            [SELECT Id, CaseNumber FROM Case WHERE Id IN :cases]);

        List<Result> results = new List<Result>();
        for (Case c : cases) {
            Result r = new Result();
            r.caseId     = c.Id;
            r.caseNumber = saved.get(c.Id).CaseNumber;
            results.add(r);
        }
        return results;
    }
}