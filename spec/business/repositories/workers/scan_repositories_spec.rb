describe Repositories::Workers::ScanRepositories do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform }

    before do
      create :repository_bitbucket
    end

    it 'queues a repository process ' do
      worker_result
      expect(Sidekiq::Queues['repositories'].size).to eq(1)
    end
  end
end
