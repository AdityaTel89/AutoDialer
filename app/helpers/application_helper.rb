module ApplicationHelper
  def status_color(status)
    case status
    when 'completed'
      'bg-green-100 text-green-800 border border-green-200'
    when 'queued', 'initiated', 'ringing', 'in-progress'
      'bg-blue-100 text-blue-800 border border-blue-200'
    when 'failed', 'busy', 'no-answer', 'canceled'
      'bg-red-100 text-red-800 border border-red-200'
    else
      'bg-gray-100 text-gray-800 border border-gray-200'
    end
  end
end
