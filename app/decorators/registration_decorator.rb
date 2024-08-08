module RegistrationDecorator

  def label
    "#{name} on #{starting_at.to_date.to_fs(:short)}"
  end

  def short_label
    #name = self.name.split
    #([name.first] + [name[1...].map { |n| n[0].upcase + "." }.join]).join(' ')
    starting_at.to_date.to_fs(:short)
  end

  def starting_at_weekday
    I18n.translate(starting_at.wday, scope: %i[map weekdays])
  end

end
