module ComparisonsHelper
  def format_hospital_variable variable, hospital
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[@comparison.base_year] if variable.is_time_series
    return '' if value.nil?

    if(variable.variable_type == :percentage)
      return '' if value.blank?
      value = value.to_f
      return "#{'%.1f' % value}%"
    end

    return !value.blank? && value.upcase == 'X' ? image_tag('accept.png', :style => 'border-style:none') : '' if variable.variable_type == :boolean
    return link_to(fa_icon('external-link-square'), value, target: '_blank', title: value) if variable.variable_type == :link
    return variable.value_by_key value, locale if variable.is_enum
    return raw value if variable.variable_type == :string
    if(variable.variable_type == :number)
      return '' if value.blank?
      value = value.to_i
      return raw "<div class='meter'><span style='width: 0%' id='numcase-#{hospital.id}-#{variable.field_name}'></span></div><div class='numcase_overlay'>#{value}</div>"
    end
    value
  end

  def hospital_variable_class variable, hospital
    classes = []
    value = hospital[variable.field_name]
    return '' if value.nil?
    value = value[@comparison.base_year] if variable.is_time_series
    limit = variable.highlight_threshold
    classes << 'orange-highlight' if(limit > 0 && limit < 100 && limit <= value)
    classes << 'text-center' if [:boolean, :link].include? variable.variable_type
    classes << 'time-series' if variable.is_time_series && hospital[variable.field_name].length > 1 && [:number, :percentage].include?(variable.variable_type)

    return classes.join(' ')
  end

  def numcase_data hospitals, variables
    data = {}
    variables.each do |var|
      next unless var.variable_type == :number
      max = 0
      hospitals.each do |h|
        num = h[var.field_name]
        next if num.blank?
        num = num[@comparison.base_year] if var.is_time_series
        next if num.blank?
        num = num.to_f
        max = [num, max].max unless num.nil? || num.nan?
      end
      hospitals.each do |h|
        num = h[var.field_name]
        next if num.blank?
        num = num[@comparison.base_year] if var.is_time_series
        next if num.blank?
        num = num.to_f
        data["#numcase-#{h.id}-#{var.field_name}"] =  (num / max) * 100.0
      end
    end
    data
  end
end
