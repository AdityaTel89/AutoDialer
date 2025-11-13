class CallsController < ApplicationController
  def index
    @calls = Call.includes(:phone_number).recent.page(params[:page]).per(50)
    
    respond_to do |format|
      format.html
      format.json { render json: @calls }
    end
  end
  
  def show
    @call = Call.find(params[:id])
  end
  
  def stats
    render json: {
      total: Call.count,
      answered: Call.where("duration > ?", 0).count,
      not_answered: Call.where("duration IS NULL OR duration = 0").count,
      average_duration: Call.average(:duration)&.round(2),
      by_status: Call.group(:status).count
    }
  end
end
