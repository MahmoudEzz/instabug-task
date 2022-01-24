class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update, :destroy]

  # GET /applications
  def index
    @applications = Application.all

    render json: @applications, except: [:id]
  end

  # GET /applications/:token
  def show
    render json: @application, except: [:id]
  end

  # POST /applications
  def create
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
      render json: @application, except: [:id], status: :created, location: @application
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/:token
  def update
    if @application.update(application_params)
      app = {
        :id => @application[:id],
        :name => @application[:name],
        :chats_count => @application[:chats_count]
      }
      serialized_app = JSON.generate(app)
      $redis.set(@application[:token], serialized_app)
      render json: @application, except: [:id]
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/:token
  def destroy
    @application.destroy
    $redis.del(@application[:token])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      serialized_app = $redis.get(params[:token])
      @application = JSON.parse(serialized_app, {:symbolize_names => true})
      if !@application
        render plain: {error: "404 Application Not Found"}, status: 404
      end
    end

    # Only allow a trusted parameter "white list" through.
    def application_params
      params.require(:application).permit(:name)
    end
end
