class MakeCallJob < ApplicationJob
  queue_as :default
  
  def perform(phone_number_id, ai_prompt = nil)
    service = CallProcessorService.new(phone_number_id, ai_prompt)
    result = service.execute
    
    unless result[:success]
      Rails.logger.error "Failed to make call: #{result[:error]}"
    end
  end
end
