describe Repositories::Workers::CreatePullRequest do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform(project.id) }

    let(:repository) { project.repository }
    let(:project) { create :project }
    let(:failure) { false }
    let(:error) { nil }

    before do
      allow(Project).to receive(:find).and_return(project)
      interactor_result = double(failure?: failure, error: error) # rubocop:disable RSpec/VerifiedDoubles
      allow(Repositories::Interactors::CreatePullRequest).to receive(:call)
        .and_return(interactor_result)
    end

    it 'calls interactor correctly' do
      worker_result
      expect(Repositories::Interactors::CreatePullRequest).to have_received(:call)
        .with({ project: project })
    end

    context 'when it fails' do
      let(:failure) { true }
      let(:error) { 'Repository pull request failed' }

      it 'raise exception' do
        expect { worker_result }.to raise_error(described_class::CreatePullRequestError)
      end
    end
  end
end
