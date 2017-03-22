class User < ActiveRecord::Base
	EMAIL_REGEX = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
	validates :email, presence: true, uniqueness: true, format: EMAIL_REGEX
	
    def new
  		@user = User.new
	end

	def create
		user = User.new(user_params)
	    if user.save
	      session[:user_id] = user.id
	      redirect_to '/'
	    else
	      redirect_to '/signup'
	    end
	end

	def donation_goal
		return (self.income.to_f * 0.03)
	end

	has_secure_password

	def generate_password_reset_token!
  		update_attribute(:password_reset_token, SecureRandom.urlsafe_base64(48))
	end

	def self.authenticate(login_password="")
	  if @user && @user.match_password(login_password)
	    return user
	  else
	    return false
	  end
	end   

end
