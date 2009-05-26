# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'login_system'

class ApplicationController < ActionController::Base
    include LoginSystem
    #model :user

    def redirect_back_or(path)
	redirect_to :back
    rescue ActionController::RedirectBackError
	redirect_to path
    end

    def login_required
	return true if session['user']
	access_denied
	return false
    end

    def access_denied
	session[:return_to] = request.request_uri
	redirect_to :controller => 'account', :action => 'login'
    end
end
