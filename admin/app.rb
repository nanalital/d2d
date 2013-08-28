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
    set :protection, :except => :frame_options

    enable  :sessions
    disable :store_location

    access_control.roles_for :any do |role|
      role.allow   '/'
      role.protect '/accounts'
    end

    access_control.roles_for :admin do |role|
      role.project_module :cities, '/cities'
      role.project_module :supporters, '/supporters'
      role.project_module :accounts, '/accounts'
    end

    access_control.roles_for :coach do |role|
      role.project_module :cities, '/cities'
      role.project_module :supporters, '/supporters'
      role.project_module :accounts, '/accounts'
    end

    access_control.roles_for :recruiter do |role|
      role.allow '/supporters/mine'
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

    get :deletelocation, :with => :id do
      if current_account
        if current_account.role = 'admin'
          l = Location.find params[:id]
          c = l.city
          l.destroy
          redirect to '/cities/edit/'+c.id.to_s
        end
      end
    end


    post :create do
      puts params
      @supporter = Supporter.new(params[:supporter])
      @supporter.account = current_account
      @supporter.acquired = Time.now
      @supporter.dd_city = current_account.city
      @supporter.dd_location = current_account.location
      amount = (@supporter.amount*100).to_s
      if @supporter.save
        @title = pat(:create_title, :model => "supporter #{@supporter.id}")
        flash[:success] = pat(:create_success, :model => 'Supporter')

        uri = URI.parse("https://online.premiumfs.co.il/Sites/greenpeace/pfsAuth.aspx")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(uri.path)
        request.add_field('Content-Type', 'application/x-www-form-urlencoded')
        testauth = "2851500dbdf34ad3a21e3eb417ffef28"
        paymauth = "22d9e751aade4446ab3dc61209b4fe52"
        request.body = "a="+amount+"&uniqnum="+@supporter.uniqnum+"&pfsAuthCode="+paymauth
        response = http.request(request)
        #puts response.value

        if response.code[0].to_i < 3
          dt = response.read_body.split('~')[1].gsub('MD=','').split('&TT=')
          @url = 'https://online.premiumfs.co.il/Sites/greenpeace/payment.aspx'
          @post = {:a=>amount,:uniqnum=>@supporter.uniqnum,:id=>"",:refURL=>"https://d2d.herokuapp.com/",:refURL_Cancel=>"",:TT=>dt[1],:MD=>dt[0],:pfsAuthCode=>paymauth,:multi_settings_id=>""}
          @verbose = response.read_body
          render 'redirect', :layout=>false
        else
          return "<html>"+response.body+"<br /><h3>response type</h3>"+response.code.to_s+' '+response.msg+"<br /><h5>--- end response ---</h5><h2>uri:</h2>"+uri.host+':'+uri.port.to_s+''+uri.path+"<br/><h2>request header:</h2>"+request.to_hash.to_s+"<br/><br/><h2>request body:</h2>"+request.body+"</html>"
        end
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
