module SimpleForm
  module Components
    module Icons
      def icon wrapper_options = nil
        template.content_tag :i, '', class: "#{options[:icon]} icon" unless options[:icon].nil?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Icons)
