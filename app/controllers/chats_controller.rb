class ChatsController < ApplicationController
  before_action :set_application, only: [:create, :show, :update, :destroy, :index]
  before_action :set_chat, only: [:show, :update, :destroy]


  # GET /applications/:application_token/chats
  def index
    begin
      @chats = Chat.where(application_id: @application[:id])
      render json: @chats, except: [:id, :application_id]
    rescue
      render json: {error: "Failed to find application chats"}, status: 400
    end
  end

  # GET /applications/:application_token/chats/1
  def show
    render json: @chat, except: [:id, :application_id]
  end

  # POST /applications/:application_token/chats
  def create
    begin 
      max_num = Chat.where(application_id: @application[:id]).maximum("number")
      number = max_num ? max_num + 1 : 1
      ChatJob.perform_async(@application[:id], number)
      render json: {number: number}, except:[:id, :application_id], status: :created
    rescue
      render json: {error: "Failed to create application chats"}, status: 400
    end
  end

  # PATCH/PUT /applications/:application_token/chats/1
  def update
    begin
      if Chat.find_by(number: chat_params[:number])
        render json: {error: "This number already exists"}, status: :unprocessable_entity
        return
      end
      
      if @chat.update(chat_params)
        render json: @chat, except: [:id, :application_id]
      else
        render json: @chat.errors, status: :unprocessable_entity
      end
    rescue
      render json: {error: "Failed to update chat"}, status: 400
    end
  end

  # DELETE /applications/:application_token/chats/1
  def destroy
    begin
      @chat.destroy
    rescue
      render json: {error: "Failed to delete application chat"}, status: 400
    end
  end

  def search
    unless params[:text].blank?
      begin
        @results = Message.search(params[:text], params[:chat_number])
        render json: @results
      rescue
        render json: {error: "Failed to search messages"}, status: 400
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      begin
        @chat = Chat.find_by(number: params[:number], application_id: @application[:id])
        if !@chat
          render json: {error: "404 Application Chat Not Found"}, status: 404
        end
      rescue
        render json: {error: "Failed to find application chat"}, status: 400
      end
    end

    # Only allow a trusted parameter "white list" through.
    def chat_params
      params.require(:chat).permit(:number)
    end

    # Set Application
    def set_application
      serialized_app = $redis.get(params[:application_token])
      if !serialized_app
        render json: {error: "404 Application Not Found"}, status: 404
      else
        @application = JSON.parse(serialized_app, {:symbolize_names => true})
      end
    end
end
