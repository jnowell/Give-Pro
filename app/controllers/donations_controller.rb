class DonationsController < ApplicationController
  before_action :require_user
  before_action :set_donation, only: [:show, :edit, :update, :destroy]
  autocomplete :non_profit, :alias

  # GET /donations
  # GET /donations.json
  def index
    #@donations = Donation.all
    @donations = Donation.where("user_id = ?", session[:user_id]).order(donation_date: :desc)
    @total_sum = 0
    @annual_sum = 0
    @exempt_sum = 0
    sub_count = Hash.new
    @date_total = Hash.new
    min_month = [@donations.last.donation_date.at_beginning_of_month,Date.today.at_beginning_of_month.prev_year].min
    cur_month = Date.today.at_beginning_of_month

    #populate month graph before beginning...necessary because hash iterates by order of insertion
    while min_month <= cur_month do
      month_in_ms = min_month.strftime('%Q')
      @date_total[month_in_ms] = 0
      min_month = min_month.next_month
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

  # GET /donations/1
  # GET /donations/1.json
  def show
  end

  # GET /donations/new
  def new
    @donation = Donation.new
  end

  # GET /donations/1/edit
  def edit
  end

  # POST /donations
  # POST /donations.json
  def create
    non_profit = NonProfit.find(params[:non_profit_id])
    @donation = Donation.new(donation_params.merge(:User => @current_user, :NonProfit => non_profit))

    respond_to do |format|
      if @donation.save
        format.html { redirect_to @donation, notice: 'Donation was successfully created.' }
        format.json { render :show, status: :created, location: @donation }
      else
        format.html { render :new }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /donations/1
  # PATCH/PUT /donations/1.json
  def update
    respond_to do |format|
      if @donation.update(donation_params)
        format.html { redirect_to @donation, notice: 'Donation was successfully updated.' }
        format.json { render :show, status: :ok, location: @donation }
      else
        format.html { render :edit }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /donations/1
  # DELETE /donations/1.json
  def destroy
    @donation.destroy
    respond_to do |format|
      format.html { redirect_to donations_url, notice: 'Donation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donation
      @donation = Donation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donation_params
      params.require(:donation).permit(:amount, :donation_date, :recurring, :matching, :User_id, :NonProfit_id)
    end
end
