class CustomersController < ApplicationController
  def index
    @customers = qbo_api.all(:customers)
    render json: @customers.as_json
  end

  def mark_inactive
    ids = params[:ids]
    logs = []

    ids.each do |id|
      begin
        qbo_api.deactivate(:customer, id: id)
        logs << { id: id, status: 'success', message: '' }
      rescue => e
        logs << { id: id, status: 'failed', message: e.message }
      end
    end

    current_account.activities.create(
      action: Activity.actions[:bulk_archive],
      entity_name: 'Customer',
      third_party_ids: ids,
      logs: logs,
      user: current_user
    )

    @customers = qbo_api.all(:customers)
    render json: { customers: @customers.as_json, logs: logs }
  end
end
