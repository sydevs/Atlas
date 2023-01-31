module Types
  class RegistrationQuestionType < Types::BaseObject
    field :slug, String, null: false
    field :title, String, null: false
    field :rows, String, null: false
  end
end
