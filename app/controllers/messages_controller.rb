class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  before_action :get_user
  before_action :check_user, except: [:index, :new, :create, :show]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Room.find(params['room_id']).messages
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)
    @message.room = Room.find(params[:room_id])
    @message.user = @current_user
    respond_to do |format|
      if @message.save
        format.html { redirect_to room_message_path(@message.room, @message), notice: 'Message was successfully created.' }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to room_messages_path, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:body)
    end

  def get_user
    if (id = User.get_id_from_token(request.params['token'] || cookies.signed['token'])) != -1
      @current_user = User.includes(:rooms_user).find(id)
      if @current_user.rooms_user.find_by(room_id: params['room_id']).nil?
        respond_to do |format|
          format.html {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
          format.json {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
        end
      end
    else
      respond_to do |format|
        format.html {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
        format.json {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
      end
    end
  end

  def check_user
    if params['id'] && @current_user.messages.where(id: params['id']).empty?
      respond_to do |format|
        format.html {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
        format.json {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
      end
    end
  end
end
