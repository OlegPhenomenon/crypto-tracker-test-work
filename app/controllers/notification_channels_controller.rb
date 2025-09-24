class NotificationChannelsController < ApplicationController
  before_action :set_notification_channel, only: [:show, :edit, :update, :destroy]

  def index
    @notification_channels = NotificationChannel.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @channel_type = params[:channel_type] || 'LogChannel'
    @notification_channel = @channel_type.constantize.new
  end

  def create
    @channel_type = params[:notification_channel][:type]
  
    if @channel_type.blank?
      @notification_channel = NotificationChannel.new
      @notification_channel.errors.add(:type, "must be selected")
      render :new, status: :unprocessable_entity
      return
    end
  
    @notification_channel = @channel_type.constantize.new(notification_channel_params)
  
    if @notification_channel.save
      redirect_to notification_channel_url(@notification_channel), notice: 'Notification channel was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @channel_type = @notification_channel.type
  end

  def update
    if @notification_channel.update(notification_channel_params)
      redirect_to notification_channel_url(@notification_channel), notice: 'Notification channel was successfully updated.'
    else
      @channel_type = @notification_channel.type
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @notification_channel.destroy
    redirect_to notification_channels_path, notice: 'Notification channel was successfully destroyed.'
  end

  def form_fields
    @channel_type = params[:channel_type]
    @notification_channel = @channel_type.constantize.new

    render partial: "channel_types/#{@channel_type.underscore}_fields",
           locals: { notification_channel: @notification_channel }
  end

  private

  def set_notification_channel
    @notification_channel = NotificationChannel.find(params[:id])
  end

  def notification_channel_params
    permitted_params = [:type]

    if params[:notification_channel][:details].present?
      case params[:notification_channel][:type]
      when 'EmailChannel'
        permitted_params << { details: [:email, :smtp_settings] }
      when 'TelegramChannel'
        permitted_params << { details: [:bot_token, :chat_id] }
      when 'LogChannel'
        permitted_params << { details: [:log_level, :log_file] }
      else
        permitted_params << { details: {} }
      end
    end

    params.require(:notification_channel).permit(permitted_params)
  end
end
