describe Projects::Workers::CheckStatusProjects do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform }

    before do
      create :project, status: :processing
    end

    it 'queues a project process' do
      worker_result
      expect(Sidekiq::Queues['projects'].size).to eq(1)
    end
  end
end
