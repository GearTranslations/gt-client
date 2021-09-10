describe Repositories::Bitbucket do
  subject(:bitbucket) do
    build :repository_bitbucket
  end

  it 'does not persist the app_password' do
    bitbucket.save
    expect(JSON.parse(bitbucket.reload.metadata_before_type_cast))
      .not_to include('app_password')
  end

  it 'persists the encrypted_app_password' do
    bitbucket.save
    expect(JSON.parse(bitbucket.reload.metadata_before_type_cast))
      .to include('encrypted_app_password')
  end
end
