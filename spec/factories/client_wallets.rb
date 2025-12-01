FactoryBot.define do
  factory :client_wallet do
    client { nil }
    wallet_type { "MyString" }
    balance { "9.99" }
    locked { false }
  end
end
