describe Projects::Workers::CheckStatusProject do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform(project.id) }

    let(:project) { create :project }
    let(:failure) { false }
    let(:error) { nil }

    before do
      interactor_result = double(failure?: failure, error: error) # rubocop:disable RSpec/VerifiedDoubles
      allow(Projects::Interactors::CheckStatus).to receive(:call)
        .and_return(interactor_result)
    end

    it 'calls interactor' do
      worker_result
      expect(Projects::Interactors::CheckStatus).to have_received(:call)
        .with({ project: project })
    end

    context 'when it fails' do
      let(:failure) { true }
      let(:error) { 'error' }

      it 'raise exception' do
        expect { worker_result }.to raise_error(described_class::CheckStatusProjectError)
      end
    end
  end
end
