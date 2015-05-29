D2d::Admin.controllers :accounts do

  def self.protect(protected)
    condition do
      return redirect back if current_account.nil? 
      redirect to '/' unless ['admin','coach'].include? current_account.role
    end if protected
  end

  before do
    citylocs = {}
    City.all.each do |c|
      locs = []
      c.locations.each {|l| locs << [l.id,l.name] }
      citylocs[c.id] = locs
    end
    @citylocs = citylocs.to_json
  end

  get :index, :protect => true do
    @title = "Accounts"
    @accounts = Account.all
    render 'accounts/index'
  end

  get :new, :protect => true do
    @admin = true
    if current_account
      if current_account.id.to_s === params[:id] or ['admin','coach'].include? current_account.role
        @admin = false
      else
        redirect to "/" 
      end
    else
      redirect to "/"
    end
    @title = pat(:new_title, :model => 'account')
    @account = Account.new
    render 'accounts/new'
  end

  post :create, :protect => true do
    @account = Account.new(params[:account])
    @account.email = nil if @account.email == ''
    if @account.save
      @title = pat(:create_title, :model => "account #{@account.id}")
      flash[:success] = pat(:create_success, :model => 'Account')
      params[:save_and_continue] ? redirect(url(:accounts, :index)) : redirect(url(:accounts, :edit, :id => @account.id))
    else
      @title = pat(:create_title, :model => 'account')
      flash.now[:error] = pat(:create_error, :model => 'account')
      render 'accounts/new'
    end
  end

  get :edit, :protect => false, :with => :id do
    @admin = true
    if current_account
      if current_account.id.to_s === params[:id] or ['admin','coach'].include? current_account.role
        @admin = false
      else
        redirect to "/" 
      end
    else
      redirect to "/"
    end
    @title = pat(:edit_title, :model => "account #{params[:id]}")
    @account = Account.find(params[:id])
    if @account
      render 'accounts/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'account', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :protect => false, :with => :id do
    if current_account
      if current_account.id.to_s === params[:id] or ['admin','coach'].include? current_account.role
      else
        redirect to "/" 
      end
    else
      redirect to "/"
    end
    @title = pat(:update_title, :model => "account #{params[:id]}")
    @account = Account.find(params[:id])
    if @account
      if params[:delete] == "Delete"
        if @account.destroy
          redirect(url(:accounts, :index))
        end
      end
      params[:account][:email] = nil if params[:account][:email] == ''
      if @account.update_attributes(params[:account])
        flash[:success] = pat(:update_success, :model => 'Account', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:accounts, :index)) :
          redirect(url(:accounts, :edit, :id => @account.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'account')
        render 'accounts/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'account', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :protect => true, :with => :id do
    @title = "Accounts"
    account = Account.find(params[:id])
    if account
      if account != current_account && account.destroy
        flash[:success] = pat(:delete_success, :model => 'Account', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'account')
      end
      redirect url(:accounts, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'account', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many, :protect => true do
    @title = "Accounts"
    unless params[:account_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'account')
      redirect(url(:accounts, :index))
    end
    ids = params[:account_ids].split(',').map(&:strip)
    accounts = Account.find(ids)
    
    if accounts.include? current_account
      flash[:error] = pat(:delete_error, :model => 'account')
    elsif Account.destroy accounts
    
      flash[:success] = pat(:destroy_many_success, :model => 'Accounts', :ids => "#{ids.to_sentence}")
    end
    redirect url(:accounts, :index)
  end
end
