/**
 * @description  Invocable Action that sends a natural-language message to an
 *               Agentforce agent and returns the agent's reply.
 *
 *               Internally it calls the standard, Salesforce-provided
 *               `generateAiAgentResponse` invocable action that every active
 *               agent exposes — the same action used by the
 *               CaseCrudAgentSingleUtterance / CaseCrudAgentMultiUtterance
 *               examples, but packaged here as a reusable @InvocableMethod so it
 *               can be surfaced as a tool on a Salesforce Hosted MCP custom
 *               server. An external MCP client (Claude, an OpenAI Responses API
 *               call, etc.) can then "talk to" the org's agent on demand.
 *
 *               Bulk-safe: accepts a list of requests and returns exactly one
 *               Result per request, in the same order.
 *
 *               Executes as the authenticated MCP / agent user, so that user's
 *               profile, field-level security, sharing rules, and the target
 *               agent's own permissions apply.
 *
 * @see          https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/custom-servers.html
 * @group        MCP Tools
 */
public with sharing class InvokeAgentAction {

    // Standard invocable action that Salesforce provides for every active agent.
    private static final String AGENT_ACTION = 'generateAiAgentResponse';

    // Default agent to talk to when a Request does not specify one. Copy this
    // from the agent's detail page in Setup (verify if invocation fails).
    private static final String DEFAULT_AGENT_API_NAME = 'Case_CRUD_Agent';

    public class AgentInvocationException extends Exception {}

    /**
     * @description Input for the tool. Each Request is one turn of conversation
     *              with the agent.
     */
    public class Request {
        @InvocableVariable(
            label='User Message'
            description='The natural-language message to send to the agent, exactly as an end user would phrase it (e.g. "Create a new case with the subject \'Laptop won\'t power on\' and priority High."). Required.'
            required=true)
        public String userMessage;

        @InvocableVariable(
            label='Session Id'
            description='Optional. The sessionId returned by a previous call to this tool. Pass it back to continue the same conversation so the agent remembers earlier turns ("that case", "the one you just created"). Omit it to start a brand-new session.')
        public String sessionId;

        @InvocableVariable(
            label='Agent API Name'
            description='Optional. API name of the agent to invoke, from the agent\'s detail page in Setup. Omit to use the default agent (Case_CRUD_Agent).')
        public String agentApiName;
    }

    /**
     * @description Output returned for each request.
     */
    public class Result {
        @InvocableVariable(
            label='Agent Response'
            description='The agent\'s natural-language reply to the user message. Surface this text to the caller.')
        public String agentResponse;

        @InvocableVariable(
            label='Session Id'
            description='The conversation sessionId. Pass this back in the next Request to continue the same multi-turn conversation with the agent.')
        public String sessionId;
    }

    /**
     * @description Sends each user message to the target agent and returns its
     *              reply. To hold a multi-turn conversation, feed the Session Id
     *              from one Result into the next Request.
     * @param  requests  one Request per message to send (bulk-safe)
     * @return one Result per input request, in the same order
     */
    @InvocableMethod(
        label='Invoke Agentforce Agent'
        description='Sends a natural-language message to an Agentforce agent and returns its reply. Use to ask an agent to do something on the user\'s behalf — create or update records, look something up, or answer a question — by describing the request in plain language. Pass back the returned Session Id to continue the same conversation.'
        category='Agentforce')
    public static List<Result> invokeAgent(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            String agentApiName = String.isBlank(req.agentApiName)
                ? DEFAULT_AGENT_API_NAME
                : req.agentApiName;

            Invocable.Action action =
                Invocable.Action.createCustomAction(AGENT_ACTION, agentApiName);
            action.setInvocationParameter('userMessage', req.userMessage);
            if (String.isNotBlank(req.sessionId)) {
                action.setInvocationParameter('sessionId', req.sessionId);
            }

            Invocable.Action.Result actionResult = action.invoke()[0];
            if (!actionResult.isSuccess()) {
                throw new AgentInvocationException(
                    'Agent "' + agentApiName + '" invocation failed: ' + actionResult.getErrors());
            }

            Map<String, Object> output = actionResult.getOutputParameters();
            Result r = new Result();
            r.agentResponse = (String) output.get('agentResponse');
            r.sessionId     = (String) output.get('sessionId');
            results.add(r);
        }

        return results;
    }
}