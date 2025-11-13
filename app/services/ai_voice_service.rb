require 'faye/websocket'
require 'eventmachine'
require 'json'

class AiVoiceService
  OPENAI_REALTIME_URL = "wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-10-01"
  
  def initialize(system_prompt = nil)
    @system_prompt = system_prompt || default_prompt
    @ws = nil
  end
  
  def connect
    EM.run do
      @ws = Faye::WebSocket::Client.new(
        OPENAI_REALTIME_URL,
        nil,
        { 
          headers: { 
            'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}",
            'OpenAI-Beta' => 'realtime=v1'
          }
        }
      )
      
      @ws.on :open do |event|
        Rails.logger.info "OpenAI Realtime connected"
        initialize_session
      end
      
      @ws.on :message do |event|
        handle_message(JSON.parse(event.data))
      end
      
      @ws.on :error do |event|
        Rails.logger.error "OpenAI WebSocket Error: #{event.message}"
      end
      
      @ws.on :close do |event|
        Rails.logger.info "OpenAI WebSocket closed"
        EM.stop
      end
    end
  end
  
  def send_audio(audio_base64)
    return unless @ws
    
    @ws.send({
      type: 'input_audio_buffer.append',
      audio: audio_base64
    }.to_json)
  end
  
  private
  
  def initialize_session
    config = {
      type: "session.update",
      session: {
        modalities: ["text", "audio"],
        instructions: @system_prompt,
        voice: "alloy", # Options: alloy, echo, shimmer
        input_audio_format: "pcm16",
        output_audio_format: "pcm16",
        input_audio_transcription: {
          model: "whisper-1"
        },
        turn_detection: {
          type: "server_vad",
          threshold: 0.5,
          prefix_padding_ms: 300,
          silence_duration_ms: 500
        },
        temperature: 0.8,
        max_response_output_tokens: 4096
      }
    }
    
    @ws.send(config.to_json)
  end
  
  def handle_message(message)
    case message['type']
    when 'session.created'
      Rails.logger.info "Session created: #{message['session']['id']}"
      
    when 'response.audio.delta'
      # Handle audio chunk from OpenAI
      audio_data = message['delta']
      # Send to Twilio Media Stream
      send_to_twilio(audio_data)
      
    when 'response.audio_transcript.delta'
      # Log what AI is saying
      Rails.logger.info "AI: #{message['delta']}"
      
    when 'conversation.item.input_audio_transcription.completed'
      # Log what user said
      Rails.logger.info "User: #{message['transcript']}"
      
    when 'response.done'
      Rails.logger.info "Response completed"
      
    when 'error'
      Rails.logger.error "OpenAI Error: #{message['error']}"
    end
  end
  
  def send_to_twilio(audio_base64)
    # This would send audio back to Twilio Media Stream
    # Requires WebSocket connection to Twilio
    # Implementation depends on your Twilio Media Stream setup
  end
  
  def default_prompt
    <<~PROMPT
      You are a helpful AI assistant making a phone call on behalf of a business.
      
      Your role:
      - Be polite, professional, and concise
      - Introduce yourself clearly
      - Ask if the person has time to talk
      - Keep responses under 20 seconds
      - If they ask to be removed, politely confirm and end the call
      
      Guidelines:
      - Speak naturally with pauses
      - Don't use complex jargon
      - Be empathetic and patient
      - End the call politely when done
    PROMPT
  end
end
