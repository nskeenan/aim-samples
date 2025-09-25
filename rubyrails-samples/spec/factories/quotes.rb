FactoryBot.define do
  factory :quote do
    quote { "This is an example quote." }
  end

  factory :quote2, class: "Quote" do
    quote { "This is the second example quote." }
    rank { "1" }
    description { "This is a test description. It should be longer than a quote and explain more." }
  end
end
