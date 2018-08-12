class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]
<<<<<<< HEAD
  before_action :check_regexes, only: [:create, :update]
=======
>>>>>>> 4f9c55b7ebfc9e659214abf5e98de785ae985d99
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
<<<<<<< HEAD
    regex = AmountRegex.new
    amount_regexes = Array.new
    amount_regexes.push regex
    org_regex = OrgRegex.new
    org_regexes = Array.new
    org_regexes.push org_regexes
    @organization = Organization.new(amount_regexes: amount_regexes, org_regexes: org_regexes)
=======
    @organization = Organization.new
>>>>>>> 4f9c55b7ebfc9e659214abf5e98de785ae985d99
  end

  # GET /non_profits/1/edit
  def edit
<<<<<<< HEAD
    amount_regexes = @organization.amount_regexes
    regex = AmountRegex.new
    amount_regexes.push regex
    @organization.amount_regexes = amount_regexes
    
    org_regexes = @organization.org_regexes
    org_regex = OrgRegex.new
    org_regexes.push org_regex
    @organization.org_regexes = org_regexes

=======
>>>>>>> 4f9c55b7ebfc9e659214abf5e98de785ae985d99
  end

  # POST /non_profits
  # POST /non_profits.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
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
    @organization.destroy
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

<<<<<<< HEAD
    def check_regexes
      amount_regexes = Array.new
      for regex in @organization.amount_regexes
        if !regex.id.nil? || !regex.regex.empty?
          amount_regexes.push regex
        end
      end
      @organization.amount_regexes = amount_regexes
      
      org_regexes = Array.new
      for regex in @organization.org_regexes
        Rails.logger.info("REGEX ID OF #{regex.id} AND REGEX OF #{regex.regex} AND EMPTY OF #{regex.regex}")
        if regex.regex.nil?
          regex.destroy
        else
          org_regexes.push regex
        end
      end
      Rails.logger.info("ORG REGEXES SIZE OF #{org_regexes.length}")
      @organization.org_regexes = org_regexes
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:ein, :name, :alias, :tax_exempt, :domain_name, :status_code, :donation_page_url, :image, :remove_image, :homepage, :type, :check_donation_string, :org_regex, amount_regexes_attributes: [:id, :regex], org_regexes_attributes: [:id, :regex])
=======
    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:ein, :name, :alias, :tax_exempt, :domain_name, :amount_regex, :status_code, :donation_page_url, :image, :remove_image, :homepage, :type, :check_donation_string, :org_regex)
>>>>>>> 4f9c55b7ebfc9e659214abf5e98de785ae985d99
    end
end
