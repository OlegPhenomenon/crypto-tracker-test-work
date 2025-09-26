class NotificationChannelsController < ApplicationController
  before_action :set_notification_channel, only: [:show, :edit, :update, :destroy]

  def index
    @notification_channels = NotificationChannel.all.order(created_at: :desc)
  end

  def show; end

  def new
    @notification_channel = NotificationChannel.new
  end

  def create
    @notification_channel = NotificationChannel.new(notification_channel_params)
    
    if @notification_channel.save
      redirect_to notification_channel_url(@notification_channel), notice: 'Notification channel was successfully created.', status: :see_other
    else
      Rails.logger.error "Notification channel creation failed: #{@notification_channel.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @notification_channel.update(notification_channel_params)
      redirect_to notification_channel_url(@notification_channel), notice: 'Notification channel was successfully updated.', status: :see_other
    else
      Rails.logger.error "Notification channel update failed: #{@notification_channel.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @notification_channel.destroy
    redirect_to notification_channels_path, notice: 'Notification channel was successfully destroyed.'
  end

  # Confidence: High
  # Category: Remote Code Execution
  # Check: UnsafeReflection
  # Message: Unsafe reflection method `constantize` called on parameter value
  # Code: params[:channel_type].constantize
  def form_fields
    # @channel_type = params[:channel_type]
    # @notification_channel = @channel_type.constantize.new

    channel_type_string = params[:channel_type]
    channel_class = NotificationChannel.descendants.find { |c| c.name == channel_type_string }
  
    if channel_class.nil?
      head :bad_request
      return
    end
  
    @notification_channel = channel_class.new

    render partial: "channel_types/notification_channel_fields",
           locals: { notification_channel: @notification_channel, channel_type: channel_type_string }
  end

  private

  def set_notification_channel
    @notification_channel = NotificationChannel.find(params[:id])
  end

  def channel_type
    if params.has_key?(:notification_channel)
      params.dig(:notification_channel, :type)
    else
      NotificationChannel.descendants.find do |channel|
        params.has_key?(channel.name.underscore)
      end.name
    end
  end

  def notification_channel_params
    channel_param_key = channel_type&.underscore
    channel_class = channel_type&.constantize

    params
      .require(channel_param_key)
      .permit(:title, details: channel_class&.permitted_details)
      .merge(type: channel_type)
  end
end
