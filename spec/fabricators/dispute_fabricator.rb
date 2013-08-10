Fabricator(:dispute) do
  reason 'testing'
  state 'new'
  message 'test.'
  owner(fabricator: :user)
end
