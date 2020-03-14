class EmailsController < ApplicationController
  before_action :member_only
  respond_to :html, :xml, :json

  def edit
    @user = User.find(params[:user_id])
    check_privilege(@user)

    respond_with(@user)
  end

  def update
    @user = User.find(params[:user_id])
    check_privilege(@user)

    if User.authenticate(@user.name, params[:user][:password])
      @user.update(email_address_attributes: { address: params[:user][:email] })
    else
      @user.errors[:base] << "Password was incorrect"
    end

    if @user.errors.none?
      flash[:notice] = "Email updated"
      respond_with(@user, location: settings_url)
    else
      flash[:notice] = @user.errors.full_messages.join("; ")
      respond_with(@user)
    end
  end

  private

  def check_privilege(user)
    raise User::PrivilegeError unless user.id == CurrentUser.id || CurrentUser.is_admin?
  end
end
