D2d::Admin.controllers :supporters do
  get :index do
    @title = "Supporters"
    @supporters = Supporter.all
    render 'supporters/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'supporter')
    @supporter = Supporter.new
    render 'supporters/new'
  end

  post :create do
    @supporter = Supporter.new(params[:supporter])
    if @supporter.save
      @title = pat(:create_title, :model => "supporter #{@supporter.id}")
      flash[:success] = pat(:create_success, :model => 'Supporter')
      params[:save_and_continue] ? redirect(url(:supporters, :index)) : redirect(url(:supporters, :edit, :id => @supporter.id))
    else
      @title = pat(:create_title, :model => 'supporter')
      flash.now[:error] = pat(:create_error, :model => 'supporter')
      render 'supporters/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "supporter #{params[:id]}")
    @supporter = Supporter.find(params[:id])
    if @supporter
      render 'supporters/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'supporter', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "supporter #{params[:id]}")
    @supporter = Supporter.find(params[:id])
    if @supporter
      if @supporter.update_attributes(params[:supporter])
        flash[:success] = pat(:update_success, :model => 'Supporter', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:supporters, :index)) :
          redirect(url(:supporters, :edit, :id => @supporter.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'supporter')
        render 'supporters/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'supporter', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Supporters"
    supporter = Supporter.find(params[:id])
    if supporter
      if supporter.destroy
        flash[:success] = pat(:delete_success, :model => 'Supporter', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'supporter')
      end
      redirect url(:supporters, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'supporter', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Supporters"
    unless params[:supporter_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'supporter')
      redirect(url(:supporters, :index))
    end
    ids = params[:supporter_ids].split(',').map(&:strip)
    supporters = Supporter.find(ids)
    
    if Supporter.destroy supporters
    
      flash[:success] = pat(:destroy_many_success, :model => 'Supporters', :ids => "#{ids.to_sentence}")
    end
    redirect url(:supporters, :index)
  end
end
