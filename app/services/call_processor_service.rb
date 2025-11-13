class CallProcessorService
  def initialize(phone_number_id, ai_prompt = nil)
    @phone_number = PhoneNumber.find(phone_number_id)
    @ai_prompt = ai_prompt
    @twilio_service = TwilioService.new
  end
  
  def execute
    @phone_number.update(status: 'calling')
    
    twilio_call = @twilio_service.make_call(
      @phone_number.number,
      @ai_prompt
    )
    
    if twilio_call.sid
      call = Call.create!(
        phone_number: @phone_number,
        twilio_sid: twilio_call.sid,
        status: 'queued',
        ai_prompt: @ai_prompt,
        started_at: Time.current
      )
      
      { success: true, call: call }
    else
      @phone_number.update(status: 'failed')
      { success: false, error: twilio_call.error }
    end
  rescue StandardError => e
    @phone_number.update(status: 'failed')
    Rails.logger.error "Call Processing Error: #{e.message}"
    { success: false, error: e.message }
  end
end
