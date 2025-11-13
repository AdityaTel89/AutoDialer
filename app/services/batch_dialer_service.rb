class BatchDialerService
  def initialize(phone_numbers, ai_prompt = nil)
    @phone_numbers = phone_numbers
    @ai_prompt = ai_prompt || "Hello, this is an automated call from our service."
    @batch_id = Time.now.to_i
  end
  
  def process
    results = {
      total: @phone_numbers.count,
      queued: 0,
      failed: 0,
      errors: []
    }
    
    @phone_numbers.each_with_index do |number, index|
      # Skip empty/invalid numbers
      next if number.blank? || number.length < 10
      
      phone_record = PhoneNumber.find_or_create_by(number: number) do |pn|
        pn.batch_id = @batch_id
        pn.uploaded_at = Time.current
      end
      
      # Queue the call with 2-second delay between calls to avoid rate limits
      MakeCallJob.set(wait: index * 2.seconds).perform_later(
        phone_record.id,
        @ai_prompt
      )
      
      results[:queued] += 1
    rescue StandardError => e
      results[:failed] += 1
      results[:errors] << { number: number, error: e.message }
      Rails.logger.error "Batch Dialer Error for #{number}: #{e.message}"
    end
    
    results
  end
end
