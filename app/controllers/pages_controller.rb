class PagesController < ApplicationController
	def show
	  create_dashboard(1)
      render template: "pages/#{params[:page]}", layout: false
    end
end
