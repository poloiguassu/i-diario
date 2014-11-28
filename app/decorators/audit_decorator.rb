class AuditDecorator
  def initialize(record)
    self.record = record
  end

  delegate :action, :audited_changes, :auditable, :user, :created_at, to: :record

  def human_attribute_name(field)
    klass.human_attribute_name field
  end

  def klass
    @klass ||= record.auditable_type.constantize
  end

  def enumeration?(field)
    enumeration(field).present?
  end

  def enumeration(field)
    klass.enumerations[field]
  end

  def enumeration_t(field, value)
    enumeration(field).t value
  end

  def parse(field, values, position)
    value = if values.is_a?(Array)
              values.send(position)
            else
              values
            end

    relation = field.to_s.gsub(/_id/, '').to_sym

    if enumeration?(field)
      enumeration_t field, value
    elsif value == false || value == true
      I18n.t "boolean.#{value}"
    elsif value.is_a?(Date) || value.is_a?(Time)
      I18n.l value
    elsif field.match(/_id/) && klass.reflect_on_association(relation).present?
      record.auditable.send relation
    else
      value
    end
  end

  protected

  attr_accessor :record
end