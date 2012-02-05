class DeliveriesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authorize_pls!, :only => [:destroy, :inbound, :new, :create]
  # GET /deliveries
  # GET /deliveries.json
  def index
    @deliveries = Delivery.order('id DESC').page(params[:page]).per(25)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deliveries }
    end
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @delivery }
    end
  end

  # GET /deliveries/new
  # GET /deliveries/new.json
  def new
    @delivery = Delivery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @delivery }
    end
  end

  # GET /deliveries/1/edit
  def edit
    @delivery = Delivery.find(params[:id])
  end

  # POST /deliveries
  # POST /deliveries.json
  def create
    @delivery = Delivery.new(params[:delivery])

    respond_to do |format|
      if @delivery.save
        format.html { redirect_to deliveries_path, notice: 'Delivery was successfully created.' }
        format.json { render json: @delivery, status: :created, location: @delivery }
      else
        format.html { render action: "new" }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /deliveries/1
  # PUT /deliveries/1.json
  def update
    @delivery = Delivery.find(params[:id])

    if current_user.extern?
      params[:delivery].delete_if{|k,v| %w{product_id purchase_order order_quantity shipped_at}.include?(k)}
    end

    respond_to do |format|
      if @delivery.update_attributes(params[:delivery])
        format.html { redirect_to deliveries_path, notice: 'Delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.json
  def destroy
    @delivery = Delivery.find(params[:id])
    @delivery.destroy

    respond_to do |format|
      format.html { redirect_to deliveries_url }
      format.json { head :no_content }
    end
  end

  def inbound
    @changed = Delivery.import_inbound_csv params[:inbound_csv], current_user
    if @changed
      # redirect_to deliveries_path, :notice => 'Import geslaagd'
      @deliveries = Delivery.order('id DESC').page(params[:page]).per(25)
      render :action => :index
    else
      redirect_to deliveries_path, :alert => 'Import failed'
    end

  end

  def outbound
    @changed = Delivery.import_outbound_csv params[:outbound_csv], current_user
    if @changed
      @deliveries = Delivery.order('id DESC').page(params[:page]).per(25)
      render :action => :index
    else
      redirect_to deliveries_path, :alert => 'Import failed'
    end

  end
end
