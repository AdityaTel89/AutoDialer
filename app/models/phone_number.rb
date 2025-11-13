class PhoneNumber < ApplicationRecord
  has_many :calls, dependent: :destroy
  
  validates :number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending calling completed failed] }
  
  scope :pending, -> { where(status: 'pending') }
  scope :by_batch, ->(batch_id) { where(batch_id: batch_id) }
  
  before_validation :normalize_number
  
  private
  
  def normalize_number
    # Format: +91XXXXXXXXXX or +18005551234 (toll-free test)
    self.number = number.to_s.gsub(/[^0-9+]/, '')
    self.number = "+91#{number}" if number.length == 10 && !number.start_with?('+')
  end
end
