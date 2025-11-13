class AiPromptParserService
  def initialize(prompt)
    @prompt = prompt
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def parse
    response = @client.chat(
      parameters: {
        model: 'gpt-4',
        messages: [
          { 
            role: 'system', 
            content: 'Extract phone number and message from user request. Return JSON with keys: phone_number (in E.164 format), message. If no phone number found, return null for phone_number.' 
          },
          { role: 'user', content: @prompt }
        ],
        functions: [{
          name: 'extract_call_info',
          description: 'Extract phone number and call message from natural language',
          parameters: {
            type: 'object',
            properties: {
              phone_number: { 
                type: 'string', 
                description: 'The phone number to call in E.164 format (e.g., +919876543210)' 
              },
              message: { 
                type: 'string', 
                description: 'The message to speak during the call' 
              }
            },
            required: ['phone_number', 'message']
          }
        }],
        function_call: { name: 'extract_call_info' }
      }
    )
    
    arguments = response.dig('choices', 0, 'message', 'function_call', 'arguments')
    JSON.parse(arguments)
  rescue StandardError => e
    Rails.logger.error "AI Parsing Error: #{e.message}"
    nil
  end
end
