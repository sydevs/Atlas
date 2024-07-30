module RegistrationDecorator

  def label
    name = self.name.split
    ([name.first] + [name[1...].map { |n| n[0].upcase + "." }.join]).join(' ')
  end

  def starting_at_weekday
    I18n.translate(starting_at.wday, scope: %i[map weekdays])
  end

end
