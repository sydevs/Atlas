module Types
  class RegistrationQuestionType < Types::BaseObject
    field :slug, String, null: false
    field :title, String, null: false
  end
end
