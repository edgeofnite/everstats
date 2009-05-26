class AccountController < ApplicationController
  layout  'default'
  before_filter :login_required, :except => [ :login ]

  def login
    @page_title = "EverStats Admin: Login"
    case request.method
      when :post
        if session['user'] = User.authenticate(params['user_login'], params['user_password'])

          flash['notice']  = "Login successful"
          redirect_to :controller => "account", :action => "welcome"
        else
          @login    = params['user_login']
          @message  = "Login unsuccessful"
      end
    end
  end
  
  def signup
    @page_title = "EverStats Admin: Signup"
    case request.method
      when :post
        @user = User.new(params['user'])
        
        if @user.save      
          session['user'] = User.authenticate(@user.login, params['user']['password'])
          flash['notice']  = "Signup successful"
          redirect_to :controller => "account", :action => "welcome"
        end
      when :get
        @user = User.new
    end      
  end  
  
    
  def logout
    @page_title = "EverStats Admin: Logout"
    session['user'] = nil
  end
    
  def welcome
    @page_title = "EverStats Admin: Welcome"
  end
  
  
  
end
