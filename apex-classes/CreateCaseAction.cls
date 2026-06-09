global with sharing class CreateCaseAction {

    global class Request {
        @InvocableVariable(
            label='Subject'
            description='Concise summary of the issue (max 255 characters).'
            required=true)
        global String subject;
    }

    global class Result {
        @InvocableVariable(label='Case ID' description='18-character Salesforce record Id')
        global Id caseId;

        @InvocableVariable(label='Case Number' description='Auto-generated Case Number')
        global String caseNumber;
    }

    @InvocableMethod(
        label='Create Case'
        description='Creates a new Salesforce support Case from a subject line and returns its record Id and Case Number.'
        category='Case Management')
    global static List<Result> createCases(List<Request> requests) {
        List<Case> cases = new List<Case>();
        for (Request req : requests) {
            cases.add(new Case(Subject = req.subject));
        }
        insert cases;

        Map<Id, Case> saved = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN :cases]);

        List<Result> results = new List<Result>();
        for (Case c : cases) {
            Result r = new Result();
            r.caseId = c.Id;
            r.caseNumber = saved.get(c.Id).CaseNumber;
            results.add(r);
        }
        return results;
    }
}