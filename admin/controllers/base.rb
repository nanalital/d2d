D2d::Admin.controllers :base do
  get :index do
    @title = "Supporters"
    @supporters = Supporter.all
    render 'index'
  end

  get :new do
    @title = pat(:new_title, :model => 'supporter')
    @supporter = Supporter.new
    render 'new'
  end

  get :thanks, :with => :id do
    @supporter = Supporter.find params[:id]
    render 'thanks'
  end

  post :create do
    @supporter = Supporter.new(params[:supporter])
    if @supporter.save
      @title = pat(:create_title, :model => "supporter #{@supporter.id}")
      flash[:success] = pat(:create_success, :model => 'Supporter')
      params[:save_and_continue] ? redirect(url(:supporters, :index)) : redirect(url(:thanks, :id => @supporter.id))
    else
      @title = pat(:create_title, :model => 'supporter')
      flash.now[:error] = pat(:create_error, :model => 'supporter')
      render 'new'
    end
  end
end
