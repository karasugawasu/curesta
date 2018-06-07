threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

if ENV['SOCKET'] then
  bind 'unix://' + ENV['SOCKET']
else
  port ENV.fetch('PORT') { 3000 }
end

environment ENV.fetch('RAILS_ENV') { 'development' }

worker_num = ENV.fetch('WEB_CONCURRENCY') { 2 }.to_i
if worker_num > 1 then
  workers worker_num
  preload_app!
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end

plugin :tmp_restart
