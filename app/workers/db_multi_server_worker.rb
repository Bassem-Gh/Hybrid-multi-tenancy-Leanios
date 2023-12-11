# app/workers/db_multi_server_worker.rb
class DbMultiServerWorker
  include Sidekiq::Worker

  def perform(task_to_run)
    # Your existing `db:multi_server` task code goes here
    # You can pass the `task_to_run` as an argument when enqueuing the job
  end
end
