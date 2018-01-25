class DisciplineLessonPlanClonerForm < ActiveRecord::Base
  has_no_table

  attr_accessor :discipline, :classroom, :start_at, :end_at, :discipline_lesson_plan_id

  validates :discipline_lesson_plan_id, presence: true
  has_many :discipline_lesson_plan_item_cloner_form
  accepts_nested_attributes_for :discipline_lesson_plan_item_cloner_form, :allow_destroy => true

  def clone!
    if valid?
      begin
        ActiveRecord::Base.transaction do
          @classrooms = Classroom.where(id: discipline_lesson_plan_item_cloner_form.map(&:classroom_id).uniq)
          discipline_lesson_plan_item_cloner_form.each do |item|
            new_lesson_plan = discipline_lesson_plan.dup
            new_lesson_plan.lesson_plan = discipline_lesson_plan.lesson_plan.dup
            new_lesson_plan.lesson_plan.contents = discipline_lesson_plan.lesson_plan.contents
            new_lesson_plan.lesson_plan.start_at = item.start_at
            new_lesson_plan.lesson_plan.end_at = item.end_at
            new_lesson_plan.lesson_plan.classroom = @classrooms.find_by_id(item.classroom_id)
            discipline_lesson_plan.lesson_plan.lesson_plan_attachments.each do |lesson_plan_attachment|
              new_lesson_plan.lesson_plan.lesson_plan_attachments << LessonPlanAttachment.new(attachment: lesson_plan_attachment.attachment)
            end
            new_lesson_plan.save!
          end
          return true
        end
      rescue ActiveRecord::RecordInvalid => e
        message = e.to_s
        message.slice!("A validação falhou: ")
        message = "Turma #{e.record.lesson_plan.try(:classroom)}: #{message}"
        errors.add(:classroom_ids, messmessage = "Turma #{e.record.lesson_plan.try(:classroom)}: #{message}")
        return false
      end
    end
  end

  def discipline_lesson_plan
    @discipline_lesson_plan ||= DisciplineLessonPlan.find(discipline_lesson_plan_id)
  end
end
