require 'google/apis/gmail_v1'
require 'google/api_client/client_secrets'
require './lib/scripts/mail_scraper.rb'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :save_income]
  before_action :check_admin, only: [:index]
  

  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "gmail-ruby-quickstart.yaml")
  WATCH_TOPIC_NAME = 'projects/optimum-battery-154220/topics/email_receipts'

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    if (@user.id != session[:user_id])
      redirect_to donations_path
    end
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    scopes = ['https://www.googleapis.com/auth/gmail.readonly']
    auth_client.update!(
      :scope => scopes,
      :redirect_uri => 'http://'+request.host_with_port + '/users/authorize'
    )
    if request['code'] == nil
        auth_uri = auth_client.authorization_uri.to_s
        redirect_to auth_uri
    else
      auth_client.code = request['code']
      auth_client.fetch_access_token!
      auth_client.client_secret = nil
      session[:credentials] = auth_client.to_json
      redirect_to :action => 'receive_oauth_code'
      end
  end

  def receive_oauth_code
    unless session.has_key?(:credentials)
      redirect to('/oauth2callback')
    end
    #puts session[:credentials].inspect
    client_opts = JSON.parse(session[:credentials])
    auth_client = Signet::OAuth2::Client.new(client_opts)

    auth_client.update!(
      :additional_parameters => {"access_type" => "offline"}
    )


    # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = "GivePro" 
    service.authorization = auth_client

    processors = ::Processor.all

    processor_string = ""
    for processor in processors
      unless processor.domain.end_with? ".org"
        processor_string << "|"
        processor_string << processor.domain
      end
    end

    puts "PROCESSOR STRING OF #{processor_string}"

    # Show the user's labels
    user_id = 'me'
    #result = service.list_user_messages(user_id, label_ids: ['CATEGORY_UPDATES'], q: "subject:(thank|receipt|contribution|donation) from:(*.org#{processor_string})")
    result = service.list_user_messages(user_id, label_ids: ['CATEGORY_UPDATES'], q: "subject:(thank|receipt|contribution|donation) from:globalgiving.org")

    count = 0
    donation_count = 0
    if result.messages
      for message in result.messages
        count += 1
        #puts "COUNT OF #{count}"
        content = ''
        message_content = service.get_user_message(user_id,message.id)
        if message_content.payload.parts.present?
          for part in message_content.payload.parts
            puts "PART OF #{part.inspect}"
            #generally part with part_id of 0 is one that has content, but not always the case
            if part.part_id = "1" and !part.body.data.blank?
              content << part.body.data
            end
          end
        elsif message_content.payload.body.data.present?
          content = message_content.payload.body.data
        end
        for header in message_content.payload.headers
           puts "HEADER NAME OF #{header.name}"
          #puts "HEADER VALUE OF #{header.value}"
          if header.name == "Subject"
            subject = header.value
          end
          if header.name == "From"
            #puts "HEADER VALUE OF #{header.value}"
            from_match = header.value.scan(/[\s\w]*<?([\w\-.]+@[\w.]+\.\w{3})>?/)
            #from_match = from_regex.match(stripped_content)
            if from_match.length > 1
              puts 'More than 1 match for From regex'
            end
            from_email = from_match[0][0].to_s
          end
          if header.name == "To"
            # ignore for now...maybe need later
          end
          if header.name == "Date"
            begin
              #Tue, 21 Mar 2017 17:40:16 +0000
              date = Date.strptime(header.value,'%a, %d %b %Y %k:%M:%S %z')
            rescue ArgumentError
              #puts "ERROR PARSING DATE #{header.value}"
              #date = Date.strptime(header.value,'%a, %b %d, %Y at %l:%M %p')
            end
          end
        end
        puts "Content of #{content}"
        if content.present?
          logged_in_user = User.find(session[:user_id])
          #puts "CALLING PARSE EMAIL WITH SUBJECT #{subject} AND FROM EMAIL #{from_email} AND TO EMAIL #{logged_in_user.email} AND DATE #{date}"
          #scraper = .new
          if MailScraper.parse_email(content, subject, from_email, logged_in_user.email, date)
            donation_count += 1
          end
        end
      end
    end

    #watch_request = Google::Apis::GmailV1::WatchRequest.new
    #watch_request.topic_name = WATCH_TOPIC_NAME
    #watch_request.label_ids = ['INBOX']

    #response = service.watch_user(user_id, watch_request)
    #puts response.inspect
    if donation_count > 0
      redirect_to donations_path
    else
      redirect_to :action => 'preview'
    end
  end

  def save_income
    @user.income = params[:user][:income]
    @goal_percent = (params[:annual_sum].to_f*100/@user.donation_goal.to_f)
    @dashboard_user = @user
    income = params[:user][:income]

    respond_to do |format|
      if @user.save
        format.html { render partial: 'shared/_income', locals: { :income => @user.income }  }
        format.json { render partial: 'shared/_income'  }
      else
        format.html { render :income }
        format.json { render :income }
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        if @user.email.end_with? "@gmail.com"
          format.html { authorize }
          format.json { authorize }
        else
          format.html { redirect_to "/users/preview", notice: 'User was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        end
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    create_dashboard(1)
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def check_admin
      logged_in_user = User.find(session[:user_id])
      unless logged_in_user.admin
        redirect_to donations_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password, :password_digest, :password_confirmation, :income)
    end
end
