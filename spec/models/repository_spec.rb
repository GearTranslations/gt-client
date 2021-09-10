describe Repository do
  subject(:repository) do
    build :repository
  end

  it { is_expected.to validate_presence_of(:workspace) }
  it { is_expected.to validate_presence_of(:repository_name) }
  it { is_expected.to validate_presence_of(:branch) }
  it { is_expected.to validate_presence_of(:metadata) }
end
