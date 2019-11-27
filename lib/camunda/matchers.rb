# RSpec matcher for topic names used for testing bpmn files
RSpec::Matchers.define :have_topics do |topic_names|
  match { |bpmn_xml| topic_names.sort == bpmn_xml.topics.sort }
  failure_message { |bpmn_xml| "Expected #{topic_names}. Found #{bpmn_xml.topics.sort}" }
end
# RSpec matcher used for testing bpmn files
RSpec::Matchers.define :have_module do |module_name_expected|
  match { |bpmn_xml| module_name_expected == bpmn_xml.module_name }
  failure_message { |bpmn_xml| "ID of the BPMN process is #{bpmn_xml.module_name}. Expected #{module_name_expected}" }
end

RSpec::Matchers.define :have_defined_classes do
  missing_classes = []
  match do |bpmn_xml|
    missing_classes = bpmn_xml.modularized_class_names.reject(&:safe_constantize)
    missing_classes.empty?
  end
  failure_message do |_bpmn_xml|
    "#{missing_classes} are not defined. They are the expected classes in your Rails app to implement the workers."
  end
end
