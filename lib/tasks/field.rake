namespace :field do
  desc 'Create a new field by combining existing fields'
  task create: :environment do
    field_name = 'knee_relevance'
    description_de = 'Relevanz Knie Orthopädie'

    var = Variable.find_by(field_name: field_name)
    if var.nil?
      Variable.create do |v|
        v.field_name = field_name
        v.rank = 200
        v.name_de = description_de
        v.is_time_series = false
        v.variable_type = 'percentage'
      end
      var = Variable.find_by(field_name: field_name)
    end

    max = -100000000
    Hospital.all.each do |h|

    end

  end

end
