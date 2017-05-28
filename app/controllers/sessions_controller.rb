class SessionsController < ApplicationController
	before_action :set_session

	def new
		puts "Session"
	end

	def create
	  user = User.find_by_email(params[:session][:email])
	  if user && user.authenticate(params[:session][:password])
	    session[:user_id] = user.id
	    @user = user
	    redirect_to donations_path
	  else
	    redirect_to '/login', :flash => { :error => "Invalid username/password. If you cannot remember your password, please use Forgot Password." } 
	  end 
	end

	def destroy 
	  session[:user_id] = nil 
	  redirect_to '/login' 
	end

	private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_session
	      #no idea why I need this, but login form seems to break otherwise
	      session[:email] = session[:email]
	      session[:password] = session[:password]
	    end

end
