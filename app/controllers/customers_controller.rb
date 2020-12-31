class CustomersController < ApplicationController
  def index
    @customers = qbo_api.all(:customers)
    render json: @customers.as_json
  end

  def with_logs
    customers = qbo_api.all(:customers)
    logs = current_account.activities.user_with_job_id(current_user, params[:job_id])

    render json: { customers: customers, logs: logs }
  end

  def mark_inactive
    @job = CustomersBulkDeleteJob.perform_later({
      ids: params[:ids], 
      account_id: current_account.id,
      user_id: current_user.id,
    })
    puts "JOB ID: #{@job.job_id}"

    render json: { job_id: @job.job_id }
  end
end
