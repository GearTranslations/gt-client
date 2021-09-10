FactoryBot.define do
  factory :repository do
    workspace { Faker::Team.name }
    repository_name { Faker::App.name }
    branch { 'mster' }
  end
end
