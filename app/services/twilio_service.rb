require 'ostruct'

class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end
  
  def make_call(to_number, ai_prompt = nil)
    call = @client.calls.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: to_number,
      url: "#{ENV['APP_HOST']}/webhooks/voice",
      status_callback: "#{ENV['APP_HOST']}/webhooks/status",
      status_callback_event: %w[initiated ringing answered completed],
      status_callback_method: 'POST',
      method: 'POST',
      timeout: 30,
      record: false
    )
    
    call
  rescue Twilio::REST::RestError => e
    Rails.logger.error "Twilio Error: #{e.message}"
    OpenStruct.new(sid: nil, error: e.message)
  end
  
  def get_call_status(call_sid)
    @client.calls(call_sid).fetch
  rescue Twilio::REST::RestError => e
    Rails.logger.error "Error fetching call: #{e.message}"
    nil
  end
end
