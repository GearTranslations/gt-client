describe Repositories::Workers::CheckPullRequests do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform }

    before do
      create :pull_request
    end

    it 'queues a pull request process ' do
      worker_result
      expect(Sidekiq::Queues['pull_requests'].size).to eq(1)
    end
  end
end
