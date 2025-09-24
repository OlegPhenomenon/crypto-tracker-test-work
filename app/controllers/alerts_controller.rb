class AlertsController < ApplicationController
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  def index
    @alerts = Alert.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @alert = Alert.new
    @available_channels = NotificationChannel.all.order(:created_at)
  end

  def create
    @alert = Alert.new(alert_params)

    # Add selected notification channels
    if params[:notification_channel_ids].present?
      selected_channels = NotificationChannel.where(id: params[:notification_channel_ids])
      @alert.notification_channels = selected_channels
    end

    if @alert.save
      redirect_to @alert, notice: "Alert was successfully created.", status: :see_other
    else
      @available_channels = NotificationChannel.all.order(:created_at)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_channels = NotificationChannel.all.order(:created_at)
  end

  def update
    # Update notification channels
    if params[:notification_channel_ids].present?
      selected_channels = NotificationChannel.where(id: params[:notification_channel_ids])
      @alert.notification_channels = selected_channels
    else
      @alert.notification_channels.clear
    end

    if @alert.update(alert_params)
      redirect_to @alert, notice: 'Alert was successfully updated.', status: :see_other
    else
      @available_channels = NotificationChannel.all.order(:created_at)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @alert.destroy
    redirect_to alerts_path, notice: 'Alert was successfully destroyed.', status: :see_other
  end

  private

  def set_alert
    @alert = Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:symbol, :threshold_price, :direction, :status, :exchange)
  end
end
