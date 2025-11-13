class DashboardController < ApplicationController
  def index
    @phone_numbers = PhoneNumber.includes(:calls).order(created_at: :desc).limit(100)
    @stats = calculate_stats
  end
  
  def upload
    unless params[:file].present?
      redirect_to root_path, alert: 'Please select a file'
      return
    end

    numbers = extract_numbers_from_file(params[:file])
    ai_prompt = params[:ai_prompt] || "Hello, this is an automated call from our service."
    
    service = BatchDialerService.new(numbers, ai_prompt)
    results = service.process
    
    redirect_to root_path, notice: "#{results[:queued]} calls queued successfully! (#{results[:failed]} failed)"
  rescue StandardError => e
    redirect_to root_path, alert: "Error: #{e.message}"
  end
  
  def paste_numbers
    numbers_text = params[:numbers]
    
    if numbers_text.blank?
      redirect_to root_path, alert: 'Please enter phone numbers'
      return
    end

    numbers = numbers_text.split(/[\n,;]/).map(&:strip).reject(&:blank?)
    ai_prompt = params[:ai_prompt] || "Hello, this is an automated call from our service."
    
    service = BatchDialerService.new(numbers, ai_prompt)
    results = service.process
    
    redirect_to root_path, notice: "#{results[:queued]} calls queued successfully! (#{results[:failed]} failed)"
  rescue StandardError => e
    redirect_to root_path, alert: "Error: #{e.message}"
  end
  
  def make_single_call
    number = params[:number]
    ai_prompt = params[:ai_prompt] || "Hello, this is an automated call from our service."
    
    if number.blank?
      render json: { success: false, error: 'Phone number is required' }, status: :unprocessable_entity
      return
    end

    phone_record = PhoneNumber.find_or_create_by(number: number)
    MakeCallJob.perform_later(phone_record.id, ai_prompt)
    
    render json: { success: true, message: "Call queued to #{number}" }
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end
  
  private
  
  def extract_numbers_from_file(file)
    extension = File.extname(file.original_filename).downcase
    
    case extension
    when '.csv'
      CSV.read(file.path, headers: true).map { |row| row['phone_number'] || row['number'] || row[0] }.compact
    when '.txt'
      File.read(file.path).split(/[\n,;]/).map(&:strip).reject(&:blank?)
    else
      raise "Unsupported file format: #{extension}. Please use CSV or TXT"
    end
  end
  
  def calculate_stats
    {
      total: Call.count,
      completed: Call.where(status: 'completed').count,
      failed: Call.where(status: ['failed', 'busy', 'no-answer', 'canceled']).count,
      in_progress: Call.where(status: %w[queued initiated ringing in-progress]).count,
      average_duration: Call.where(status: 'completed').average(:duration)&.to_i || 0
    }
  end
end
