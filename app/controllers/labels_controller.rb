class LabelsController < ApplicationController
  before_filter :authenticate_user!
  def index
    respond_to do |format|
      format.pdf do
        @ids = (params[:range] || '').split(',').map(&:to_i)
        @deliveries = Delivery.where(:id => @ids)
        #response.headers['Content-Disposition'] = "attachment;filename=labels#{Time.now.strftime("%Y%m%d%_H%M%S")}.pdf"
        render 'index'
      end
    end
  end
end
