module RegistrationDecorator

  def label
    name
  end

  def starting_at_weekday
    I18n.translate(starting_at.wday, scope: %i[map weekdays])
  end

end
