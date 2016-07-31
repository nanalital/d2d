# encoding: utf-8
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

    set :delivery_method, :smtp => {
      :address              => 'smtp-out-pool.greenpeace.org',
      :port                 => 25
    }

    set :admin_model, 'Account'
    set :login_page,  '/sessions/new'
    set :protection, :except => :frame_options

    enable  :sessions
    disable :store_location

    access_control.roles_for :any do |role|
      role.allow   '/'
      role.allow   '/dd'
      role.allow   '/result'
      role.allow   '/payment_response'
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
      role.allow '/accounts/edit'
    end

    $title = 'd2d'
    $pagedesc = 'Greenpeace Israel Donation Site'
    $pageauthor = 'GP Israel'
    $pagekeyws = 'envirnment, greenpeace, donation'
    $sitemail = 'donation@greenpeace.org.il'
    $cities = ['Tel Aviv', 'Jerusalem','Haifa']
    $prices = [150,100,75]

    enable :sessions

    get :recruit do
      recruit
    end

    get :dd do
      @title = "Supporters"
      @supporters = Supporter.all
      render 'index'
    end

    get :index do
      @title = "Donate"
      @supporter = Supporter.new
      @web = true 
      @show_form = 1
      @background_image = set_background_image
      session[:donate] = 1
      render 'new_donate', :layout => :web_donate
    end

    get :new do
      @title = pat(:new_title, :model => 'supporter')
      @supporter = Supporter.new
      render 'new'
    end

    get :thanks, :with => :id do
      @sup = Supporter.find(params[:id])
      begin
        deliver(:main, :thank_you_email, @sup) if @sup.email.present?
      rescue => e
        p "Error in sending email to #{@sup}, exception => #{e}"
      end

      if session[:donate].present?
        @background_image = set_background_image
        render 'landingpage/_thanks', :layout => :web_donate
      else
        render 'thanks'
      end
    end

    mailer :main do
      email :thank_you_email do |supporter, root_url|
        from $sitemail
        to   supporter.email
        content_type :html
        subject  "תודה על תרומתך הראשונה לגרינפיס"
        body render('thanks', :locals => {:sup => supporter, :root_url => root_url} )
      end
    end

    get :recruit do
      recruit
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

    get :payment_response do
      p "got to payment_response with params #{params}"
      return if params['p1'] == "000" # continue if payment succeeded
      @sup = Supporter.find_by_uniqnum("p"+params["p120"].split('p')[1])
      unless @sup
        puts "sup #{params['p120']} not found"
        return
      else
        @sup.result = "payment failed with status: #{params['p1']}"
        @sup.key = params["key"]
        @sup.cc_last4d = params["p5"]
        @sup.cc_expiry = params["p30"]
        @sup.amount = params["p36"].to_i / 100
        @sup.cc_voucher = params["p96"]
        @sup.citizen_id = params["p200"]
        @sup.cc_holder = params["p201"]
        @sup.save
        return
      end
    end

    get :result do
      @sup = Supporter.find_by_uniqnum("p"+params["p120"].split('p')[1])
      layout = :application
      layout = :web if params["web"] == 1
      return render 'failure', :layout => layout unless params["p1"] == "000"
      unless @sup
        puts "sup #{params['p120']} not found"
        return render 'failure', :layout => layout
      else
        @sup.result = "payment succeeded"
        @sup.key = params["key"]
        @sup.cc_last4d = params["p5"]
        @sup.cc_expiry = params["p30"]
        @sup.amount = params["p36"].to_i / 100
        @sup.cc_voucher = params["p96"]
        @sup.citizen_id = params["p200"]
        @sup.cc_holder = params["p201"]
        if @sup.save
          return render 'thanks', :layout => layout
        else
          return render 'failure', :layout => layout
        end
      end
    end

    post :create do
      #testrefURL = '0.0.0.0:3000/success'
      #testauth = "2851500dbdf34ad3a21e3eb417ffef28"
      #testauthurl = 'https://online.premiumfs.co.il/Sites/opencarttest/pfsAuth.aspx'
      #testpaymurl = 'https://online.premiumfs.co.il/Sites/opencarttest/payment.aspx'

      # paymrefURL = 'med.greenpeace.org/israel/d2d/success'
      paymrefURL = 'http://joinus.gpi.org.il/success'
      paymauth = "22d9e751aade4446ab3dc61209b4fe52"
      paymauthurl = "https://ws.payplus.co.il/Sites/greenpeace2/pfsAuth.aspx"
      paympaymurl = "https://ws.payplus.co.il/Sites/greenpeace2/payment.aspx"

      # refURL = 'https://med.greenpeace.org/israel/d2d/thankyou/'
      refURL = 'http://joinus.gpi.org.il/thanks/'
      errorURL = 'https://d2d.herokuapp.com/payment_response/'

      # validation prepare
      params['supporter']['account_id'] = nil if params['supporter']['account_id'].to_i == 0
      params['supporter']['dd_location'] = nil if params['supporter']['dd_location'].to_i == 0
      # for independent donation
      @web = params.delete('web')
      params['supporter']['account_id'] = 555 if @web

      @supporter = Supporter.new(params['supporter'])
      @supporter.acquired = Time.now
      amount = (@supporter.amount*100).to_s if @supporter.amount

      if @supporter.save
        @title = pat(:create_title, :model => "supporter #{@supporter.id}")
        flash[:success] = pat(:create_success, :model => 'Supporter')
        handle_cancel and return if params[:cancel_btn].present?

        uri = URI.parse(paymauthurl)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(uri.path)
        request.add_field('Content-Type', 'application/x-www-form-urlencoded')
        request.body = "a="+amount+"&uniqnum="+@supporter.uniqnum+"&pfsAuthCode="+paymauth
        response = http.request(request)
        #puts response.value
        if response.code[0].to_i < 3
          dt = response.read_body.split('~')[1].gsub('MD=','').split('&TT=')
          puts "Before payment post -> dt: #{dt}, supporter uniqnum: #{@supporter.uniqnum}"
          @url = paympaymurl
          @post = { :a=>amount,
                    :uniqNum=>@supporter.uniqnum,
                    :id=>"",
                    :refURL=>refURL + @supporter.id,
                    :refURL_Cancel=>env["HTTP_ORIGIN"],
                    :refURL_TrasError=>errorURL,
                    :TT=>dt[1],
                    :MD=>dt[0],
                    :pfsAuthCode=>paymauth,
                    :multi_settings_id=>"" }
          @verbose = nil#response.read_body

          if params[:form_donate] == '1'
            @background_image = set_background_image
            render 'new_donate', :layout => :web_donate
          else
            render 'redirect', :layout=>false
          end
        else
          return "<html>"+response.body+"<br /><h3>response type</h3>"+response.code.to_s+' '+response.msg+"<br /><h5>--- end response ---</h5><h2>uri:</h2>"+uri.host+':'+uri.port.to_s+''+uri.path+"<br/><h2>request header:</h2>"+request.to_hash.to_s+"<br/><br/><h2>request body:</h2>"+request.body+"</html>"
        end
      else
        handle_cancel and return if params[:cancel_btn].present?
        @title = pat(:create_title, :model => 'supporter')
        flash.now[:error] = pat(:create_error, :model => 'supporter')
        @web ? render('new', :layout => :web) : render('new')
      end
    end

    def handle_cancel
      if @supporter.first_name.present? && @supporter.last_name.present? && @supporter.account_id.present? &&
        (@supporter.email.present? || @supporter.mobile_phone.present? || @supporter.home_phone.present?)
        @supporter.result = "canceled"
        @supporter.save(:validate => false)
      end
      redirect_to '/' and return true
    end

    def price_range_manual
      # in use in _form_donate.haml
      @range = []
      (200..500).each do |n|
        @range.push(["#{n}" + ' ש"ח', "#{n}"]) if n%50 == 0
      end
      (600..1000).each do |n|
        @range.push(["#{n}" + ' ש"ח', "#{n}"]) if n%100 == 0
      end
      (1500..5000).each do |n|
        @range.push(["#{n}" + ' ש"ח', "#{n}"]) if n%500 == 0
      end
      @range
    end

    def set_background_image
      bg_domain = 'http://www.gpi.org.il/signup/images'
      bg_random = (1..10).to_a.sample
      if params[:bg].present?
        session[:bg] = "#{bg_domain}/#{params[:bg]}.jpg"
        return session[:bg]
      else
        return "#{bg_domain}/#{bg_random}.jpg"
      end
    end

    # Custom error management 
    error(403) { @title = "Error 403"; render('errors/403', :layout => :error) }
    error(404) { @title = "Error 404"; render('errors/404', :layout => :error) }
    error(500) { @title = "Error 500"; render('errors/500', :layout => :error) }
  end
end