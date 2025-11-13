class Call < ApplicationRecord
  belongs_to :phone_number
  
  validates :status, inclusion: { 
    in: %w[queued initiated ringing in-progress completed busy failed no-answer canceled] 
  }
  
  scope :successful, -> { where(status: 'completed') }
  scope :failed, -> { where(status: %w[failed busy no-answer canceled]) }
  scope :recent, -> { order(created_at: :desc) }
  
  def duration_formatted
    return "0:00" unless duration
    minutes = duration / 60
    seconds = duration % 60
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end
  
  def answered?
    status == 'completed' && duration.to_i > 0
  end
end
