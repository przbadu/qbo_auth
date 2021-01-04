class CustomersController < ApplicationController
  def index
    @customers = customers_with_pagination
    render json: { customers: @customers.as_json, totalResult: total_customers }
  end

  def with_logs
    customers = customers_with_pagination
    activity = current_account.activities.where(user: current_user, job_id: params[:job_id]).first

    render json: { customers: customers, activity: activity, totalResult: total_customers }
  end

  def mark_inactive
    ### TODO:
    ### Fix with Batch Operation
    ### https://github.com/minimul/qbo_api#batch-operations-limit-30-operations-in-1-batch-request
    @job = CustomersBulkDeleteJob.perform_later({
      ids: params[:ids],
      account_id: current_account.id,
      user_id: current_user.id,
    })
    puts "JOB ID: #{@job.job_id}"

    render json: { job_id: @job.job_id }
  end

  def export
    ids = params[:ids]
    @job = CustomersExportJob.perform_later({
      ids: params[:ids],
      account_id: current_account.id,
      user_id: current_user.id
    })
    puts "JOB ID: #{@job.job_id}"

    render json: { job_id: @job.job_id }
  end

  private

  def filter_params
    @q = params.dig(:q) || ''
    @page = params[:page].to_i + 1
    @per_page = params[:per] || 50
    @offset = @page <= 1 ? 1 : (@page.to_i * @per_page - @per_page)
  end

  def customers_with_pagination
    filter_params
    query = "SELECT * FROM Customer "
    query += " WHERE DisplayName = '#{qbo_api.esc(@q)}'" if @q.present?
    query += " STARTPOSITION #{@offset} MAXRESULTS #{@per_page}"
    puts "TEST: #{query}"
    qbo_api.query(query)
  end

  def total_customers
    response = qbo_api.query(%{SELECT COUNT(*) FROM Customer})
    response['QueryResponse']['totalCount']
  end
end
