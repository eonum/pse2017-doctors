module HospitalsHelper
  def hop_format_hospital_variable variable, comparison
    value = @hospital[variable.field_name]
    return blank_value(variable) if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    return blank_value(variable) if value.nil?

    if(variable.variable_type == :percentage)
      return '' if value.blank?
      value = value.to_f
      return "#{'%.1f' % value}%"
    end

    return (!value.blank? && value.upcase == 'X') ? image_tag('accept.png', :style => 'border-style:none') : I18n.t('no_boolean') if variable.variable_type == :boolean
    return link_to(fa_icon('external-link-square'), value, target: '_blank', title: value) if variable.variable_type == :link
    return variable.value_by_key value, locale if variable.is_enum
    return raw value if variable.variable_type == :string
    if(variable.variable_type == :number)
      return '' if value.blank?
      value = value.to_i
      return value
    end
    if(variable.variable_type == :relevance)
      return '' if value.blank?
      value = value.to_f
      return raw "<div class='meter relevance'><span style='width: 0%' id='numcase-#{variable.field_name}'></span></div><div class='numcase_overlay'>#{value}%</div>"
    end
    value
  end

  def blank_value variable
    return variable.variable_type == :boolean ? I18n.t('no_boolean') : ''
  end

  def hop_numcase_data comparisons
    data = {}
    comparisons.each do |comparison|
      comparison.variables.each do |var|
        next unless var.variable_type == :relevance
        num = @hospital[var.field_name]
        next if num.blank?
        num = num[comparison.base_year] if var.is_time_series
        next if num.blank?
        data["#numcase-#{var.field_name}"] = num.to_f
      end
    end
    data
  end

  def hop_hospital_variable_class variable, comparison
    classes = []
    value = @hospital[variable.field_name]
    return '' if value.nil?
    value = value[comparison.base_year] if variable.is_time_series
    limit = variable.highlight_threshold
    classes << 'orange-highlight' if(limit > 0 && limit < 100 && limit <= value)
    classes << 'time-series' if variable.is_time_series && @hospital[variable.field_name].length > 1 && [:number, :percentage, :relevance].include?(variable.variable_type)

    return classes.join(' ')
  end

end
