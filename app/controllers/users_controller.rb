class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_admin!

  def index
    @users = User.order('email ASC').page(params[:page]).per(25)
  end

  def new
    @user = User.new
  end

  def create
    role = params[:user].delete(:role)
    @user = User.new(params[:user])
    @user.role = role if role
    respond_to do |format|
      if @user.save
        format.html {redirect_to users_path, notice: 'User was successfully created.'}
      else
        format.html {render action: "new"}
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    role = params[:user].delete(:role)
    @user.attributes = params[:user]
    @user.role = role if role
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end

  private

end


