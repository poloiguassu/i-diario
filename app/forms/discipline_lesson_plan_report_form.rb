class DisciplineLessonPlanReportForm
  include ActiveModel::Model

  attr_accessor :unity_id,
                :classroom_id,
                :discipline_id,
                :date_start,
                :date_end,
                :teacher_id,
                :report_type,
                :author

  validates :date_start, presence: true, date: true, timeliness: {
    on_or_before: :date_end,
    type: :date,
    on_or_before_message: 'não pode ser maior que a Data final'
  }
  validates :date_end, presence: true, date: true, timeliness: {
    on_or_after: :date_start,
    type: :date,
    on_or_after_message: 'deve ser maior ou igual a Data inicial'
  }
  validates :unity_id,
            :classroom_id,
            :discipline_id,
            :teacher_id,
            :author,
            presence: true

  validate :must_have_records

  def discipline_lesson_plan
    DisciplineLessonPlan.by_unity_id(unity_id)
                        .by_author(author, teacher_id)
                        .by_classroom_id(classroom_id)
                        .by_discipline_id(discipline_id)
                        .by_date_range(date_start.to_date, date_end.to_date)
                        .order_by_lesson_plan_date
  end

  def discipline_content_record
    DisciplineContentRecord.by_unity_id(unity_id)
                           .by_author(author, teacher_id)
                           .by_classroom_id(classroom_id)
                           .by_discipline_id(discipline_id)
                           .by_date_range(date_start.to_date, date_end.to_date)
                           .order_by_content_record_date
  end

  private

  def must_have_records
    return if errors.present?

    if report_type == '1'
      errors.add(:discipline_lesson_plan, :must_have_discipline_lesson_plan) if discipline_lesson_plan.count.zero?
    elsif discipline_content_record.count.zero?
      errors.add(:discipline_lesson_plan, :must_have_discipline_lesson_plan)
    end
  end
end
