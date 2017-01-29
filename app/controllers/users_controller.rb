require 'google/apis/gmail_v1'
require 'google/api_client/client_secrets'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :save_income]
  

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
      redirect_to '/'
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
    puts session[:credentials].inspect
    client_opts = JSON.parse(session[:credentials])
    auth_client = Signet::OAuth2::Client.new(client_opts)

    auth_client.update!(
      :additional_parameters => {"access_type" => "offline"}
    )


    # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = "GivePro" 
    service.authorization = auth_client

    # Show the user's labels
    user_id = 'me'
    result = service.list_user_messages(user_id, label_ids: ['INBOX'], q: "from:*.org")
    
    for message in result.messages
      message_content = service.get_user_message(user_id,message.id)
      for header in message_content.payload.headers
        if header.name == "Subject"
          #puts header.value
        end
      end
    end

    watch_request = Google::Apis::GmailV1::WatchRequest.new
    watch_request.topic_name = WATCH_TOPIC_NAME
    watch_request.label_ids = ['INBOX']

    response = service.watch_user(user_id, watch_request)
    puts response.inspect

    redirect_to :action => 'preview'
  end

  def save_income
    @dashboard_user.income = params[:user][:income]
    @goal_percent = (params[:annual_sum].to_f*100/@user.donation_goal.to_f)
    @saved_user = @user
    income = params[:user][:income]
    puts "Goal percentage of " + @goal_percent.to_s

    respond_to do |format|
      if @user.save
        format.html { render partial: 'shared/_income', locals: { :income => income }  }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password, :password_digest, :password_confirmation, :income)
    end
end
