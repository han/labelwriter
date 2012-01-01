class LabelsController < ApplicationController
  def index
    respond_to do |format|
      format.pdf do
        @ids = (params[:range] || '').split(',').map(&:to_i)
        render 'index'
      end
    end
  end
end
