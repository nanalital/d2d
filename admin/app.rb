module D2d
  class Admin < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Admin::AccessControl

    require 'net/http'

    ##
    # Application configuration options
    #
    # set :raise_errors, true         # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true          # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true      # Shows a stack trace in browser (default for development)
    # set :logging, true              # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, "foo/bar"   # Location for static assets (default root/public)
    # set :reload, false              # Reload application files (default in development)
    # set :default_builder, "foo"     # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"         # Set path for I18n translations (default your_app/locales)
    # disable :sessions               # Disabled sessions by default (enable if needed)
    # disable :flash                  # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout              # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    set :admin_model, 'Account'
    set :login_page,  '/sessions/new'

    enable  :sessions
    disable :store_location

    access_control.roles_for :any do |role|
      role.protect '/accounts'
      role.protect '/supporters'
      role.allow   '/sessions'
    end


    access_control.roles_for :admin do |role|
    role.project_module :supporters, '/supporters'
    role.project_module :accounts, '/accounts'
    end

    access_control.roles_for :user do |role|
    end

    $title = 'd2d'
    $pagedesc = 'Greenpeace Israel Donation Site'
    $pageauthor = 'GP Israel'
    $pagekeyws = 'envirnment, greenpeace, donation'
    $sitemail = 'donation@greenpeace.org.il'
    $cities = ['Tel Aviv', 'Jerusalem','Haifa']
    $prices = [150,100,75]

    enable :sessions

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
      puts params
      @supporter = Supporter.new(params[:supporter])
      @supporter.account = current_account
      @supporter.dd_city = current_account.city
      @supporter.dd_location = current_account.location
      if @supporter.save
        @title = pat(:create_title, :model => "supporter #{@supporter.id}")
        flash[:success] = pat(:create_success, :model => 'Supporter')

        uri = URI.parse("https://online.premiumfs.co.il/Sites/opencarttest/pfsAuth.aspx")
        http = Net::HTTP.new(uri.host)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new("/v1.1/auth")
        request.add_field('Content-Type', 'application/x-www-form-urlencoded')
        request.body = {'a' => @supporter.amount, 'uniqnum'=>@supporter.uniqnum, 'pfsAuthCode'=>'2851500dbdf34ad3a21e3eb417ffef28'}
        response = http.request(request)

        puts response
      else
        @title = pat(:create_title, :model => 'supporter')
        flash.now[:error] = pat(:create_error, :model => 'supporter')
        render 'new'
      end
    end

    # Custom error management 
    error(403) { @title = "Error 403"; render('errors/403', :layout => :error) }
    error(404) { @title = "Error 404"; render('errors/404', :layout => :error) }
    error(500) { @title = "Error 500"; render('errors/500', :layout => :error) }
  end
end
