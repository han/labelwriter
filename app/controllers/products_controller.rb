class ProductsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authorize_pls!, :except => [:index, :show, :barcode]
  # GET /products
  # GET /products.json
  def index
    @products = Product.order('item_code ASC').page(params[:page]).per(25)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  def barcode
    @product = Product.find(params[:product_id])

    respond_to do |format|
      format.png { send_data @product.barcode, :disposition => 'inline', :type => 'image/png'}
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_path, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to products_path, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    @product.delete!

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  def import
    if Product.import_csv(params[:products_csv], params[:fetimcodes_csv])
      redirect_to products_path, :notice => 'Import succeeded'
    else
      redirect_to products_path, :alert => 'Import failed'
    end
  end

  def export
    products = Product.all
    respond_to do |format|
      format.csv { export_csv(products) }
    end
  end

  private

  BOM = "\uFEFF" #Byte Order Mark

  def export_csv(products)
    content = (BOM + Product.to_csv(products)).encode('UTF-16le')
    send_data content, :filename => "products_#{I18n.l(Time.now, :format => :short)}.csv"
  end

end
