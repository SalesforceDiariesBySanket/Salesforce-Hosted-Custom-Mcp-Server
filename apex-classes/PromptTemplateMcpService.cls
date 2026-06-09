public with sharing class PromptTemplateMcpService {

    private static final String DEFAULT_APPLICATION_NAME = 'PromptTemplateGenerationsInvocable';

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
            ConnectApi.WrappedValue recordValue = new ConnectApi.WrappedValue();
            recordValue.value = new Map<String, String>{ 'id' => recordId };

            ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            input.additionalConfig.applicationName = DEFAULT_APPLICATION_NAME;
            input.isPreview = false;
            input.inputParams = new Map<String, ConnectApi.WrappedValue>{ inputName => recordValue };

            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(templateName, input);

            String text = (output?.generations != null && !output.generations.isEmpty()) ? output.generations[0].text : null;

            if (String.isBlank(text)) {
                result.errorMessage = 'The prompt template returned no content.';
                return result;
            }
            result.isSuccess = true;
            result.responseText = text;
        } catch (Exception e) {
            result.errorMessage = 'Could not generate a response: ' + e.getMessage();
        }

        return result;
    }

    public class PromptResult {
        @AuraEnabled public Boolean isSuccess = false;
        @AuraEnabled public String responseText;
        @AuraEnabled public String errorMessage;
    }
}