class WorkspacesController < ApplicationController
  def index
    @alert = Alert.new
    @alerts = Alert.all
    @available_channels = NotificationChannel.all.order(:created_at)
  end

  def create
    @alert = Alert.new(alert_params)

    if params[:notification_channel_ids].present?
      selected_channels = NotificationChannel.where(id: params[:notification_channel_ids])
      @alert.notification_channels = selected_channels
    end

    if @alert.save
      redirect_to workspaces_path, notice: "Alert was successfully created.", status: :see_other
    else
      @alerts = Alert.all
      @available_channels = NotificationChannel.all.order(:created_at)

      Rails.logger.error "Alert creation failed: #{@alert.errors.full_messages.join(', ')}"
      render :index, status: :unprocessable_entity
    end
  end

  private

  def alert_params
    params.require(:alert).permit(:symbol, :threshold_price, :direction, :status, :exchange)
  end
end
