class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user 

  def current_user 
    @current_user ||= User.find(session[:user_id]) if session[:user_id] 
  end

  def require_user 
  	redirect_to '/login' unless current_user 
  end

  def create_dashboard(user_id)
    @donations = Donation.where("user_id = ?", user_id).order(donation_date: :desc)
    @total_sum = 0
    @annual_sum = 0
    @exempt_sum = 0
    sub_count = Hash.new
    @date_total = Hash.new

    unless @donations.empty?
      min_month = [@donations.last.donation_date.at_beginning_of_month,Date.today.at_beginning_of_month.prev_year].min
      cur_month = Date.today.at_beginning_of_month
      
      #populate month graph before beginning...necessary because hash iterates by order of insertion
      while min_month <= cur_month do
        month_in_ms = min_month.strftime('%Q')
        @date_total[month_in_ms] = 0
        min_month = min_month.next_month
      end
    end


    for donation in @donations
      @total_sum += donation.amount

      if donation.donation_date.year == cur_month.year
        @annual_sum += donation.amount
        if donation.NonProfit.exemption_code > 0
          @exempt_sum += donation.amount
        end
      end


      if sub_count[donation.NonProfit.subsection]
        sub_count[donation.NonProfit.subsection] += donation.amount
      else
        sub_count[donation.NonProfit.subsection] = donation.amount
      end

      month = donation.donation_date.at_beginning_of_month.strftime('%Q')
      if @date_total[month]
        @date_total[month] += donation.amount
      else
        @date_total[month] = donation.amount
      end
    end

    sub_labels = Hash.new
    sub_labels[1] = "Corporations"
    sub_labels[2] = "Title-Holding Corporations"
    sub_labels[3] = "Charities & Religious Orgs"
    sub_labels[4] = "Social Welfare"
    sub_labels[5] = "Labor & Agriculture"
    sub_labels[6] = "Business"
    sub_labels[7] = "Social & Recreational"
    sub_labels[8] = "Fraternal"
    sub_labels[9] = "Employee Beneficiaries"
    sub_labels[10] = "Domestic Fraternal"
    sub_labels[11] = "Teacher Retirement Funds"
    sub_labels[12] = "Life Insurance Associations"
    sub_labels[13] = "Cemetery Companies"
    sub_labels[14] = "Credit Unions"
    sub_labels[15] = "Mutual Insurance"
    sub_labels[16] = "Crop Operations"
    sub_labels[17] = "Unemployment"
    sub_labels[18] = "Pension Trusts"
    sub_labels[19] = "Veterans"
    sub_labels[20] = "Legal Service"
    sub_labels[21] = "Black Lung Trusts"
    sub_labels[22] = "Multiemployer Pension"
    sub_labels[23] = "Pre-1880 Veterans"
    sub_labels[24] = "Section 4049 Trusts"
    sub_labels[25] = "Trusts for Multiple Parents"
    sub_labels[26] = "State-Sponsored High Risk Health Coverage"
    sub_labels[27] = "Workers Comp"

    @sub_hash = Hash.new
    sub_count.each do |key,value|
      @sub_hash[sub_labels[key]] = value
    end
  end
end
