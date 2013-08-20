D2d::Admin.controllers :cities do
  get :index, :protect => true do
    @title = "Cities"
    @cities = City.all
    render 'cities/index'
  end

  get :new, :protect => true do
    @title = pat(:new_title, :model => 'city')
    @city = City.new
    render 'cities/new'
  end

  post :create, :protect => true do
    @city = City.new(params[:city])
    if @city.save
      @title = pat(:create_title, :model => "city #{@city.id}")
      flash[:success] = pat(:create_success, :model => 'City')
      params[:save_and_continue] ? redirect(url(:cities, :index)) : redirect(url(:cities, :edit, :id => @city.id))
    else
      @title = pat(:create_title, :model => 'city')
      flash.now[:error] = pat(:create_error, :model => 'city')
      render 'cities/new'
    end
  end

  get :edit, :protect => true, :with => :id do
    @title = pat(:edit_title, :model => "city #{params[:id]}")
    @city = City.find(params[:id])
    if @city
      if @city.locations.last
        if @city.locations.last.name
          l = @city.locations.build if @city.locations.last.name.length > 0
        end
      end
      render 'cities/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'city', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :protect => true, :with => :id do
    @title = pat(:update_title, :model => "city #{params[:id]}")
    @city = City.find(params[:id])
    if @city
      new = params[:location][:new]
      if new
        if new.length > 0
          l = Location.new
          l.name = new
          l.city = @city
          l.save
        end
      end
      params[:location].each do |k,v|
        l = nil
        l = Location.find k.to_i unless k == 'new'
        if l
          l.name = v
          l.save
        end
      end
      if @city.update_attributes(params[:city])
        flash[:success] = pat(:update_success, :model => 'City', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:cities, :index)) :
          redirect(url(:cities, :edit, :id => @city.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'city')
        render 'cities/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'city', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :protect => true, :with => :id do
    @title = "Cities"
    city = City.find(params[:id])
    if city
      if city.destroy
        flash[:success] = pat(:delete_success, :model => 'City', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'city')
      end
      redirect url(:cities, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'city', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many, :protect => true do
    @title = "Cities"
    unless params[:city_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'city')
      redirect(url(:cities, :index))
    end
    ids = params[:city_ids].split(',').map(&:strip)
    cities = City.find(ids)
    
    if City.destroy cities
    
      flash[:success] = pat(:destroy_many_success, :model => 'Cities', :ids => "#{ids.to_sentence}")
    end
    redirect url(:cities, :index)
  end
end
