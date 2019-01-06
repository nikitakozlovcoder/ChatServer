class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :get_user
  before_action :check_admin, only: [ :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
      respond_to do |format|
        if @room.update(room_params)
          format.html { redirect_to @room, notice: 'Room was successfully updated.' }
          format.json { render :show, status: :ok, location: @room }
        else
          format.html { render :edit }
          format.json { render json: @room.errors, status: :unprocessable_entity }
        end
      end
  end
  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:name)
    end

    def get_user
      if (id = User.get_id_from_token(request.params['token'] || cookies.signed['token'])) != -1
       @current_user = User.includes(:rooms_user).find(id)
        if params['id'] && @current_user.rooms_user.find_by(room_id: params['id']).nil?
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
  def check_admin
    p params
    if @current_user.rooms_user.find_by(:room_id => params['id']).role != "admin"
      respond_to do |format|
        format.html {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
        format.json {render(json: {error: "unauthorized connection, try re-login."}, status: 401) and return}
      end
    end
  end
end
