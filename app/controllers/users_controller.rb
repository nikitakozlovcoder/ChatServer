class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :auth_user, only: [:edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
 # protect_from_forgery with: :null_session
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end
 # GET
  def login_view
    @user = User.new
  end
  #POST
  def login
    @user = User.new(params.require(:user).permit(:mail, :password))
    @user.login = true
    unless @user.valid?
      respond_to do |format|
        format.html {render "login_view" and return}
        format.json {render(json: @user.errors, status: :created, location: @userMain) and return}
      end
    end
    @userMain = User.find_by(mail: params['user']['mail'])
    puts "!!!!!!!!!"
    puts params['user']['password']
    puts @userMain.id
    puts @userMain.authenticate(params['user']['password'])
    puts "!!!!!!!!!"
    if @userMain && @userMain.authenticate(params['user']['password'])
      cookies.signed[:token] = @userMain.gen_token
      respond_to do |format|
        payload = {token: @userMain.gen_token }
        format.html { redirect_to @userMain }
        format.json { render json: payload, status: :created, location: @userMain }
      end
    else
      @user.errors.add(:credentials, "Mail or password not right")
      respond_to do |format|
        format.html {render "login_view", status: 401}
        format.json {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
      end
    end

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
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.register(params)
    puts "!!!!!!!!!"
    p @user.errors
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        payload = {:token => @user.gen_token, user: @user}
        format.json { render json: payload, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
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
    def auth_user
      puts request.params['token']
      puts User.get_id_from_token(request.params['token'])
      puts params['id']
      token = request.params['token'] || cookies.signed['token']
      unless token && (id = User.get_id_from_token(token)) && id != -1 && id == params['id'].to_i
        respond_to do |format|
          format.html {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
          format.json {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
        end
      end



      #render json: {error: "unauthorized connection"}, status: 401
      #request.params['token'] && id != -1 && id == params['id']
    end

  private
    def set_user
      @user = User.find(params[:id])
    end


    def user_params
      params.require(:user).permit(:name, :password, :password_confirmation)
    end
end
