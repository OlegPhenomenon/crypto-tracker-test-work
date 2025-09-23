class WorkspacesController < ApplicationController
  def index
    @alert = Alert.new
    @alerts = Alert.all
  end

  def create
    @alert = Alert.new(alert_params)
    
    # Create notification channels based on selected types
    if params[:notification_channels].present?
      params[:notification_channels].each do |channel_type, channel_data|
        if channel_data[:selected] == '1'
          channel = channel_type.constantize.find_or_create_by(details: channel_data[:details] || {})
          @alert.notification_channels << channel
        end
      end
    end

    if @alert.save
      redirect_to workspaces_path, notice: "Alert was successfully created.", status: :see_other
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def alert_params
    params.require(:alert).permit(:symbol, :threshold_price, :direction, :status, :exchange)
  end
end
