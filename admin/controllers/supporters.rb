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
    redirect_to 'supporters/export' and return if Supporter.first.nil?
    strd = Date.parse Supporter.first.acquired.to_s
    endd = Date.today
    if params[:supporter][:start].length > 0
      strd = Date.strptime(params[:supporter][:start],'%d/%m/%Y')
    end
    if params[:supporter][:end].length > 0
      endd = Date.strptime(params[:supporter][:end],'%d/%m/%Y')
    end
    @sups = Supporter.where('acquired <= ?',endd+1.days).where('acquired >= ?',strd)
    #puts @sups
    #puts @sups.count
    hdrline = '"debit date","token","cc exp date","cc holder","amount on the spot","amount regular","cc number","first name","last name","gender","birthdate","ssn","home phone","mobile","email","address","city","post code","occupation","receive updates?","cc voucher id","dd_id","dd_location_id","uniqnum","notes","result"'
    File.open('tmp/sup.csv',"w:utf-8") do |output|
      output << hdrline+"\n"
      @sups.each do |s|

        line = []
        line << s.acquired.strftime('%d/%m/%Y')
        line << s.key
        line << s.cc_expiry
        line << s.cc_holder
        line << s.intended_amount
        line << s.amount.to_s
        line << ''
        line << s.first_name ? s.first_name.gsub("\"", '') : s.first_name
        line << s.last_name ? s.last_name.gsub("\"", '') : s.last_name
        line << s.gender == 1 ? 'm' : 'f'
        line << (s.birthday.nil? ? '' : s.birthday)
        line << s.citizen_id
        line << s.home_phone
        line << s.mobile_phone
        line << s.email
        line << s.address ? s.address.gsub("\"", '') : s.address
        line << s.city ? s.city.gsub("\"", '') : s.city
        line << s.zip_code
        line << s.occupation ? s.occupation.gsub("\"", '') : s.occupation
        line << s.receive_updates ? 't' : 'f'
        line << s.cc_voucher
        begin
          if (s.account)
            account = s.account
            location = Location.find (s.dd_location.to_i)
          end
          line << account.old_id
          line << location.other_id
        rescue
          3.times {line << ''}
        end
        line << s.uniqnum
        line << s.notes
        line << s.result
=begin
        line << s.cc_last4d
        line << (s.account ? s.account.name : '')
        begin
          if (s.dd_city)
            city = City.find (s.dd_city.to_i)
            location = Location.find (s.dd_location.to_i)
          end

          line << city.other_id
          line << city.name
          line << location.other_id
          line << location.name
        rescue
          4.times {line << ''}
        end
        line << s.member_name
        line << s.member_phone
=end
        output << '"'+line.join('","')+'"'+"\n"
      end
    end

    send_file 'tmp/sup.csv', :type=> :csv, :filename => "gp_supporters_#{strd.strftime('%d.%m')}-#{endd.strftime('%d.%m')}.csv"

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
