class ApplicationMailer < ActionMailer::Base
  default from: "postmaster@givepro.io"
  layout 'mailer'

  def password_reset(user)
	  @user = user
	  mail(to: "#{user.email}",
	       subject: "Reset Your Password")
	end
end
