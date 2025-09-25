class WorkspacesController < ApplicationController
  def index
    @alert = Alert.new
    @alerts = Alert.all
    @available_channels = NotificationChannel.all.order(:created_at)
  end

  def create
    @alert = Alert.new(alert_params)

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
    params.require(:alert).permit(:symbol, :threshold_price, :direction, :status, :exchange, notification_channel_ids: [])
  end
end
