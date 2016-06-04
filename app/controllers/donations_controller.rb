class DonationsController < ApplicationController
  before_action :require_user, except: [:preview, :read_receipt]
  before_action :set_donation, only: [:show, :edit, :update, :destroy]
  autocomplete :non_profit, :alias
  

  # GET /donations
  # GET /donations.json
  def index
    #@donations = Donation.all
    create_dashboard(session[:user_id])
    @user = @current_user
    @saved_user = @user
    @income = @user.income
  end

  # GET /donations/1
  # GET /donations/1.json
  def show
  end

  # GET /donations/new
  def new
    @donation = Donation.new(:donation_date => Date.today)
  end

  # GET /donations/1/edit
  def edit
  end

  def preview
    if session[:user_id]
      redirect_to :action => 'index'
    end
    @user = User.find(1)
    if @user
      create_dashboard(1)
    end
  end

  # POST /donations
  # POST /donations.json
  def create
    if params[:non_profit_id].present?
      non_profit = NonProfit.find(params[:non_profit_id])
    end
    @donation = Donation.new(donation_params.merge(:User => @current_user, :NonProfit => non_profit))

    respond_to do |format|
      if @donation.save
        format.html { redirect_to donation_url, notice: 'Donation was successfully created.' }
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
        format.html { redirect_to donations_url, notice: 'Donation was successfully updated.' }
        format.json { render :show, status: :ok, location: @donation }
      else
        format.html { render :edit }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  def read_receipt
    if params[:token] && (params[:token] == 'test_token')
      puts "READ RECEIPT CALLED WITH MESSAGE OF" +params[:message_id].to_s
      Aws.config.update({
        region: 'us-east-1',
        credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_KEY"])
      })
      s3 = Aws::S3::Client.new(region: 'us-east-1')
      resp = s3.get_object({bucket: 'donations-bucket', key: params[:message_id]})
      contents = resp.body.read

      from = contents.match(/(?<=From: )(.*?)(?=\n)/).try(:to_s)
      to = contents.match(/(?<=To: )(.*?)(?=\n)/).try(:to_s)
      subject = contents.match(/(?<=Subject: )(.*?)(?=\n)/).try(:to_s)
      body = contents.match(/(?<=Content-Type: text\/html; charset\=UTF-8)(.*?)(?=--)/m).try(:to_s)
      puts "Body of #{body}"
      #render text: 'email created', status: :created 
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
      params.require(:donation).permit(:amount, :donation_date, :recurring, :matching, :User_id, :non_profit_id)
    end
end
