# rubocop:disable all

require_relative 'job_scheduler'

RSpec.describe JobScheduler do
  let(:scheduler) { JobScheduler.new }

  it "schedules a job to run at the correct time" do
    executed = false
    job = scheduler.schedule(Time.now + 2, -> { executed = true })

    sleep 3
    expect(executed).to be true
  end

  it "cancels a job before it runs" do
    executed = false
    job = scheduler.schedule(Time.now + 2, -> { executed = true })
    scheduler.cancel(job)

    sleep 3
    expect(executed).to be false
  end

  it "executes multiple jobs concurrently" do
    execution_times = []
    mutex = Mutex.new

    job1 = scheduler.schedule(Time.now + 2, -> { mutex.synchronize { execution_times << Time.now } })
    job2 = scheduler.schedule(Time.now + 2, -> { mutex.synchronize { execution_times << Time.now } })

    sleep 3

    expect(execution_times.length).to eq(2)
    expect((execution_times[1] - execution_times[0]).abs).to be < 0.5
  end
end
