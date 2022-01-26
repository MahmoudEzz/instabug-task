class MessagesController < ApplicationController
  before_action :set_application, only: [:create, :show, :update, :destroy, :index]
  before_action :set_chat, only: [:create, :show, :update, :destroy, :index]
  before_action :set_message, only: [:show, :update, :destroy]

  # GET /applications/:application_token/chats/:chat_number/messages
  def index
    begin
      @messages = Message.where(chat_id: @chat[:id])
      render json: @messages, except: [:id, :chat_id]
    rescue
      render json: {error: "Failed to get application chat messages"}, status: 400
    end
  end

  # GET /applications/:application_token/chats/:chat_number/messages/1
  def show
    render json: @message, except: [:id, :chat_id]
  end

  # POST /applications/:application_token/chats/:chat_number/messages
  def create
    begin
      if message_params[:text]
        max_num = Message.where(chat_id: @chat[:id]).maximum("number")
        number = max_num ? max_num + 1 : 1
        new_message = {
          chat_id: @chat[:id],
          number: number,
          text: message_params[:text]
        }
        MessageJob.perform_async(new_message);
        render json: new_message, except: [:chat_id], status: :created
      end
    rescue
      render json: {error: "Failed to create new message"}, status: 400
    end

  end

  # PATCH/PUT /applications/:application_token/chats/:chat_number/messages/1
  def update
    begin
      if Message.find_by(number: message_params[:number])
        render json: {error: "This number already exists"}, status: :unprocessable_entity
        return
      end
  
      if @message.update(message_params)
        render json: @message, except: [:id, :chat_id]
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    rescue
      render json: {error: "Failed to update message"}, status: 400
    end
  end

  # DELETE /applications/:application_token/chats/:chat_number/messages/1
  def destroy
    begin
      @message.destroy
    rescue
      render json: {error: "Failed to delete message"}, status: 400
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      serialized_app = $redis.get(params[:application_token])
      if !serialized_app
        render json: {error: "404 Application Not Found"}, status: 404
      else
        @application = JSON.parse(serialized_app, {:symbolize_names => true})
      end
    end

    def set_chat
      begin
        @chat = Chat.find_by(number: params[:chat_number], application_id: @application[:id])
        if !@chat
          render json: {error: "404 Application Chat Not Found"}, status: 404
        end
      rescue
        render json: {error: "Failed to get chat"}, status: 400
      end
    end

    def set_message
      begin
        @message = Message.find_by(number: params[:number],chat_id: @chat[:id])
        if !@message
          render json: {error: "404 Application Chat Message Not Found"}, status: 404
        end
      rescue
        render json: {error: "Failed to get message"}, status: 400
      end
    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      params.require(:message).permit(:number, :chat_id, :text)
    end
end
