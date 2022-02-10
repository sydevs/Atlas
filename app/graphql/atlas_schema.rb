class AtlasSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # TODO: Figure out why this directive doesn't load
  # directive(Directives::LocalizeDirective)
end
