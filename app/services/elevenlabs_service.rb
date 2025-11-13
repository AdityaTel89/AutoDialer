require 'net/http'
require 'json'
require 'uri'

class ElevenlabsService
  API_BASE_URL = 'https://api.elevenlabs.io/v1'
  
  def initialize
    @api_key = ENV['ELEVENLABS_API_KEY']
    @voice_id = ENV['ELEVENLABS_VOICE_ID'] || 'EXAVITQu4vr4xnSDxMaL' # Default: Rachel
  end

  # Generate audio and return URL (requires hosting the audio somewhere)
  def generate_audio_url(text)
    audio_data = generate_audio(text)
    
    # You would need to:
    # 1. Save audio_data to a file
    # 2. Upload to S3 or similar
    # 3. Return public URL
    # For now, we'll use Twilio's <Say> as fallback
    
    nil # Return nil to fallback to Twilio TTS
  end

  # Generate raw audio data
  def generate_audio(text)
    uri = URI("#{API_BASE_URL}/text-to-speech/#{@voice_id}/stream")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['xi-api-key'] = @api_key
    request['Content-Type'] = 'application/json'
    request.body = {
      text: text,
      model_id: 'eleven_monolingual_v1',
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.75,
        style: 0.0,
        use_speaker_boost: true
      }
    }.to_json

    response = http.request(request)
    
    if response.code.to_i == 200
      response.body # Returns binary audio data (MP3)
    else
      Rails.logger.error "ElevenLabs Error: #{response.code} - #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "ElevenLabs Error: #{e.message}"
    nil
  end

  # List available voices
  def list_voices
    uri = URI("#{API_BASE_URL}/voices")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri)
    request['xi-api-key'] = @api_key
    
    response = http.request(request)
    JSON.parse(response.body)['voices'] if response.code.to_i == 200
  rescue StandardError => e
    Rails.logger.error "ElevenLabs Error: #{e.message}"
    []
  end
end
