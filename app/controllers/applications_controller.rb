class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update, :destroy]

  # GET /applications
  def index
    begin
      @applications = Application.all
      render json: @applications, except: [:id]
    rescue
      render json: @applications.errors, status: :unprocessable_entity
    end
  end

  # GET /applications/:token
  def show
    render json: @application, except: [:id]
  end

  # POST /applications
  def create
    begin
      @application = Application.new(application_params)
      if @application.save
        app = {
          :id => @application[:id],
          :name => @application[:name],
          :chats_count => @application[:chats_count],
          :chats => []
        }
        serialized_app = JSON.generate(app)
        $redis.set(@application[:token], serialized_app)
        render json: @application, except: [:id], status: :created
      end
    rescue
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/:token
  def update
    begin
      if @application.update(application_params)
        app = {
          :id => @application[:id],
          :name => @application[:name],
          :chats_count => @application[:chats_count]
        }
        serialized_app = JSON.generate(app)
        $redis.set(@application[:token], serialized_app)
        render json: @application, except: [:id]
      end
    rescue
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/:token
  def destroy
    begin
      @application.destroy
      $redis.del(@application[:token])
    rescue
      render json: {error: "Failed to delete chat"}, status: 400
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by(token: params[:token])
      if !@application
        render json: {error: "404 Application Not Found"}, status: 404
      end
    end

    # Only allow a trusted parameter "white list" through.
    def application_params
      params.require(:application).permit(:name)
    end
end
