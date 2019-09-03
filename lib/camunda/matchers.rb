RSpec::Matchers.define :have_module do
  module_name = nil
  match do |bpmn_path|
    bpmn_path = Rails.root.join(bpmn_path)
    doc = Nokogiri::XML(File.open(bpmn_path))
    module_name = doc.xpath('/bpmn:definitions/bpmn:process').first['id']
    module_ = module_name.safe_constantize
    module_&.is_a?(Module)
  end
  failure_message do |bpmn_path|
    "#{module_name} is not defined as a module. It is the process ID in #{bpmn_path}"
  end
end

RSpec::Matchers.define :have_classes do
  missing_classes = []
  match do |bpmn_path|
    bpmn_path = Rails.root.join(bpmn_path)
    doc = Nokogiri::XML(File.open(bpmn_path))
    module_name = doc.xpath('/bpmn:definitions/bpmn:process').first['id']
    doc.xpath('//*[@camunda:type="external"]').each do |task|
      class_name = task.attribute('id').value
      full_class_name = "#{module_name}::#{class_name}"
      missing_classes << full_class_name unless full_class_name.safe_constantize
    end
    missing_classes.empty?
  end
  failure_message do |bpmn_path|
    "#{missing_classes} are not defined. They are the expected classes to implement the workers from #{bpmn_path}."
  end
end
