FactoryBot.define do
  factory :locale_file do
    name { 'locale/es.json' }
    repository { create :repository_bitbucket }
  end
end
