D2d::Admin.controllers :sessions do
  def self.authenticate(old_id, password)
    account = Account.where("old_id = ?", old_id).first if old_id.present?
    account && account.has_password?(password) ? account : nil
  end

  get :new do
    render "/sessions/new"
  end

  post :create do
    if account = D2d::Admin.authenticate(params[:old_id], params[:password])
      set_current_account(account)
      redirect url(:base, :index)
    elsif Padrino.env == :development && params[:bypass]
      account = Account.first
      set_current_account(account)
      redirect url(:base, :index)
    else
      params[:old_id], params[:password] = h(params[:old_id]), h(params[:password])
      flash[:error] = "Authentication error"
      redirect url(:sessions, :new)
    end
  end

  delete :destroy do
    set_current_account(nil)
    redirect url(:sessions, :new)
  end
end
