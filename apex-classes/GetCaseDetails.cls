public without sharing class GetCaseDetails {
    @InvocableMethod(
        label='Get Case Details'
        description='Fetches Id, Status, Priority, and Subject for a Case by its CaseNumber')
    public static List<Response> getDetails(List<Request> requests) {
        String caseNumber = requests[0].case_number;
        Id contactId = (Id) requests[0].contact_id;

        Case c = [
            SELECT Id, Status, Priority, Subject
            FROM Case
            WHERE CaseNumber = :caseNumber AND ContactId = :contactId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Response r = new Response();
        r.case_id = c.Id;
        r.status = c.Status;
        r.priority = c.Priority;
        r.subject = c.Subject;
        return new List<Response>{ r };
    }

    public class Request {
        @InvocableVariable(required=true description='The human-readable CaseNumber')
        public String case_number;

        @InvocableVariable(required=true description='The verified Contact.Id')
        public String contact_id;
    }

    public class Response {
        @InvocableVariable(description='The 18-character Salesforce Id of the Case')
        public String case_id;
        @InvocableVariable(description='Case.Status value')
        public String status;
        @InvocableVariable(description='Case.Priority value')
        public String priority;
        @InvocableVariable(description='Case.Subject value')
        public String subject;
    }
}