class MessagesController < ApplicationController
  before_action :set_application, only: [:create, :show, :update, :destroy, :index]
  before_action :set_chat, only: [:create, :show, :update, :destroy, :index]
  before_action :set_message, only: [:show, :update, :destroy]

  # GET /applications/:application_token/chats/:chat_number/messages
  def index
    @messages = Message.where(chat_id: @chat[:id])

    render json: @messages, except: [:id, :chat_id]
  end

  # GET /applications/:application_token/chats/:chat_number/messages/1
  def show
    render json: @message, except: [:id, :chat_id]
  end

  # POST /applications/:application_token/chats/:chat_number/messages
  def create
    # Todo -> solve phantom record problem
    app_messages = Message.where(chat_id: @chat[:id])
    number = app_messages.length + 1
    new_message = {
      chat_id: @chat[:id],
      number: number,
      text: message_params[:text]
    }
    @message = Message.new(new_message)

    if @message.save
      @chat.messages_count =+ 1
      @chat.save

      render json: @message, except: [:id, :chat_id], status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/:application_token/chats/:chat_number/messages/1
  def update
    puts "=============IN============="
    if Message.find_by(number: message_params[:number])
      render json: {error: "This number already exists"}, status: :unprocessable_entity
      return
    end

    if @message.update(message_params)
      render json: @message, except: [:id, :chat_id]
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/:application_token/chats/:chat_number/messages/1
  def destroy
    @message.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by(token: params[:application_token])
      if !@application
        render plain: {error: "404 Application Not Found"}, status: 404
      end
    end

    def set_chat
      @chat = Chat.find_by(number: params[:chat_number], application_id: @application[:id])
      if !@chat
        render json: {error: "404 Application Chat Not Found"}, status: 404
      end
    end

    def set_message
      @message = Message.find_by(number: params[:number],chat_id: @chat[:id])
      if !@message
        render json: {error: "404 Application Chat Message Not Found"}, status: 404
      end
    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      params.require(:message).permit(:number, :chat_id, :text)
    end
end
