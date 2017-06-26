class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]
  before_action :check_admin

  # GET /non_profits
  # GET /non_profits.json
  def index
    if params[:name]
      @organizations = Organization.where("alias LIKE ?", "#{params[:name]}%")
    else
      @organizations = Organization.all
    end
  end

  # GET /non_profits/1
  # GET /non_profits/1.json
  def show
  end

  # GET /non_profits/new
  def new
    @organization = Organization.new
  end

  # GET /non_profits/1/edit
  def edit
  end

  # POST /non_profits
  # POST /non_profits.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @non_profit.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /non_profits/1
  # PATCH/PUT /non_profits/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /non_profits/1
  # DELETE /non_profits/1.json
  def destroy
    @non_profit.destroy
    respond_to do |format|
      format.html { redirect_to organization_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    def check_admin
      logged_in_user = User.find(session[:user_id])
      unless logged_in_user.admin
        redirect_to '/'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:ein, :name, :alias, :tax_exempt, :domain_name, :amount_regex, :status_code, :donation_page_url, :image, :remove_image, :homepage, :type, :check_donation_string, :org_regex)
    end
end
