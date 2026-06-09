/**
 * @description  Runs a Prompt Builder template for a single record and returns
 *               the generated text. Exposed as an MCP tool / agent action through
 *               an ExternalServiceRegistration (the OpportunityMcpService pattern):
 *               the @AuraEnabled method below is the contract the registration
 *               surfaces, and its ApexDoc becomes the tool description.
 *
 *               Adapted from PromptTemplateController (the promptTemplateRunner
 *               LWC controller) for headless MCP / agent use.
 *
 *               Executes as the authenticated user, so that user's "Execute
 *               Prompt Templates" permission, sharing, and FLS apply.
 *
 * @see          https://developer.salesforce.com/docs/ai/agentforce/guide/agent-auraenabled.html
 * @group        MCP Tools
 */
public with sharing class PromptTemplateMcpService {

    // Application name used by the official Apex examples for isPreview = false.
    private static final String DEFAULT_APPLICATION_NAME = 'PromptTemplateGenerationsInvocable';

    /**
     * Runs a Prompt Builder template against a single record and returns the
     * generated text.
     *
     * Use this to generate grounded content — a summary, an outreach email, a
     * recommendation — for a specific record by naming the prompt template and
     * the record that grounds it.
     *
     * @param templateName       Developer name (or Id) of the prompt template to run.
     * @param recordId           Id of the record that grounds the template.
     * @param inputParameterName Reference name of the template input (e.g. "Input:Account").
     *        Pass null to default to "Input:Account".
     * @return The generated text plus success / error details.
     */
    @AuraEnabled
    public static PromptResult runPromptTemplate(String templateName, String recordId, String inputParameterName) {
        PromptResult result = new PromptResult();

        if (String.isBlank(templateName)) {
            result.errorMessage = 'A prompt template name is required.';
            return result;
        }
        if (String.isBlank(recordId)) {
            result.errorMessage = 'A record Id is required to ground the prompt.';
            return result;
        }
        String inputName = String.isBlank(inputParameterName) ? 'Input:Account' : inputParameterName;

        try {
            // The template expects a record reference: a map keyed by "id".
            ConnectApi.WrappedValue recordValue = new ConnectApi.WrappedValue();
            recordValue.value = new Map<String, String>{ 'id' => recordId };

            ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            input.additionalConfig.applicationName = DEFAULT_APPLICATION_NAME;
            input.isPreview = false;
            input.inputParams = new Map<String, ConnectApi.WrappedValue>{ inputName => recordValue };

            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(templateName, input);

            String text = (output?.generations != null && !output.generations.isEmpty())
                ? output.generations[0].text
                : null;

            if (String.isBlank(text)) {
                result.errorMessage = 'The prompt template returned no content.';
                return result;
            }
            result.isSuccess = true;
            result.responseText = text;
        } catch (Exception e) {
            result.errorMessage = 'Could not generate a response: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, result.errorMessage);
        }

        return result;
    }

    /** Structured outcome returned to the MCP client / agent. */
    public class PromptResult {
        @AuraEnabled public Boolean isSuccess = false;
        @AuraEnabled public String responseText;
        @AuraEnabled public String errorMessage;
    }
}