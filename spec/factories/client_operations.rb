FactoryBot.define do
  factory :client_operation do
    client { nil }
    client_wallet { nil }
    operation_type { "MyString" }
    amount { "9.99" }
    balance_before { "9.99" }
    balance_after { "9.99" }
    reference { "MyString" }
    status { "MyString" }
  end
end
