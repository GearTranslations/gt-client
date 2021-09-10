describe Repositories::Workers::ScanRepository do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform(repository.id) }

    let(:repository) { create :repository_bitbucket }
    let(:failure) { false }
    let(:error) { nil }

    before do
      allow(Repository).to receive(:find).and_return(repository)
      interactor_result = double(failure?: failure, error: error) # rubocop:disable RSpec/VerifiedDoubles
      allow(repository).to receive(:scan).and_return(interactor_result)
    end

    it 'calls interactor correctly' do
      worker_result
      expect(repository).to have_received(:scan)
    end

    context 'when it fails' do
      let(:failure) { true }
      let(:error) { 'Repository scan failed' }

      it 'raise exception' do
        expect { worker_result }.to raise_error(described_class::ScanRepositoryError)
      end
    end
  end
end
