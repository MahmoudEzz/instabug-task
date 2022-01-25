class ChatsController < ApplicationController
  before_action :set_application, only: [:create, :show, :update, :destroy, :index]
  before_action :set_chat, only: [:show, :update, :destroy]


  # GET /applications/:application_token/chats
  def index
    @chats = Chat.where(application_id: @application[:id])

    render json: @chats, except: [:id]
  end

  # GET /applications/:application_token/chats/1
  def show
    render json: @chat, except: [:id]
  end

  # POST /applications/:application_token/chats
  def create
    max_num = Chat.where(application_id: @application[:id]).maximum("number")
    number = max_num ? max_num + 1 : 1
    ChatJob.perform_async(@application[:id], number)
    render json: {number: number}, except:[:id], status: :created
  end

  # PATCH/PUT /applications/:application_token/chats/1
  def update
    
    if Chat.find_by(number: chat_params[:number])
      render json: {error: "This number already exists"}, status: :unprocessable_entity
      return
    end
    
    if @chat.update(chat_params)
      render json: @chat, except: [:id]
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/:application_token/chats/1
  def destroy
    @chat.destroy
  end

  def search
    unless params[:text].blank?

      @results = Message.search(params[:text], params[:chat_number])
      render json: @results
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.find_by(number: params[:number], application_id: @application[:id])
      if !@chat
        render json: {error: "404 Application Chat Not Found"}, status: 404
      end
    end

    # Only allow a trusted parameter "white list" through.
    def chat_params
      params.require(:chat).permit(:number, :messages_count)
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
