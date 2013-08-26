D2d::Admin.controllers :supporters do
  get :index, :protect => true do
    @title = "Supporters"
    @supporters = Supporter.all
    render 'supporters/index'
  end

  get :mine, :protect => false do
    @title = "My Supporters"
    @supporters = current_account.supporters
    puts @supporters
    render 'supporters/index'
  end

  get :export, :protect => true do
    @title = "Export Supporters"
    render 'supporters/export'
  end

  post :export, :protect => true do
    puts params
    strd = Date.parse Supporter.first.acquired.to_s
    endd = Date.today
    if params[:supporter][:start].length > 0
      strd = Date.strptime(params[:supporter][:start],'%d/%m/%Y')
    end
    if params[:supporter][:end].length > 0
      endd = Date.strptime(params[:supporter][:end],'%d/%m/%Y')
    end
    puts strd
    puts endd
    @sups = Supporter.where('acquired <= ?',endd+1.days).where('acquired >= ?',strd)
    puts @sups
    puts @sups.count
    hdrline = '"UniqNum","Date","DD_Recruiter","DD_City","DD_Location","First Name","Last Name","Gender","Birthday","Occupation","City","Address","Post code","Home Phone","Mobile Phone","E-mail","Receive updates?","AP amount"'
    File.open('tmp/sup.csv',"w:utf-8") do |output|
      output << hdrline+"\n"
      @sups.each do |s|
        line = []
        line << s.uniqnum
        line << s.acquired.strftime('%d/%m/%Y')
        line << s.account.name if s.account
        line << s.dd_city.name if s.dd_city
        line << s.dd_location.name if s.dd_location
        line << s.first_name
        line << s.last_name
        line << s.gender == 1 ? 'm' : 'f'
        if s.birthday
          line << s.birthday.strftime('%d/%m/%Y')
        else
          line << ''
        end
        line << s.occupation
        line << s.city
        line << s.street_name+' '+s.num_building+' / '+s.num_apartment
        line << s.zip_code
        line << s.home_phone
        line << s.mobile_phone
        line << s.email
        line << s.receive_updates ? 't' : 'f'
        line << s.ap_monthly
        output << '"'+line.join('","')+'"'+"\n"
      end
    end

    send_file 'tmp/sup.csv', :type=> :csv

  end

  get :new, :protect => true do
    @title = pat(:new_title, :model => 'supporter')
    @supporter = Supporter.new
    render 'supporters/new'
  end

  post :create, :protect => true do
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

  get :edit, :protect => true, :with => :id do
    @title = pat(:edit_title, :model => "supporter #{params[:id]}")
    @supporter = Supporter.find(params[:id])
    if @supporter
      render 'supporters/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'supporter', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :protect => true, :with => :id do
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

  delete :destroy, :protect => true, :with => :id do
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

  delete :destroy_many, :protect => true do
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
