class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def voice
    call_sid = params['CallSid']
    call = Call.find_by(twilio_sid: call_sid)
    ai_prompt = call&.ai_prompt || "Hello, this is an automated call from our service."
    
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say(message: ai_prompt, voice: 'alice')
      r.pause(length: 1)
      r.say(message: "Goodbye!", voice: 'alice')
    end
    
    render xml: response.to_s
  end
  
  def status
    call_sid = params['CallSid']
    status = params['CallStatus']
    duration = params['CallDuration']
    
    call = Call.find_by(twilio_sid: call_sid)
    
    if call
      call.update(
        status: status,
        duration: duration&.to_i,
        ended_at: (status == 'completed' ? Time.current : nil)
      )
      
      if call.phone_number
        call.phone_number.update(
          status: case status
                  when 'completed' then 'completed'
                  when 'failed', 'busy', 'no-answer', 'canceled' then 'failed'
                  else 'idle'
                  end
        )
      end
    end
    
    head :ok
  end
end
