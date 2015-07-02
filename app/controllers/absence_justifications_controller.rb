class AbsenceJustificationsController < ApplicationController
  has_scope :page, default: 1
  has_scope :per, default: 10

  def index
    @absence_justifications = apply_scopes(AbsenceJustification.includes(:student).ordered)

    authorize @absence_justifications
  end

  def new
    @absence_justification = AbsenceJustification.new.localized
    @absence_justification.absence_date = Date.today

    authorize @absence_justification
  end

  def create
    @absence_justification = AbsenceJustification.new(resource_params)

    authorize @absence_justification

    if @absence_justification.save
      respond_with @absence_justification, location: absence_justifications_path
    else
      render :new
    end
  end

  def edit
    @absence_justification = AbsenceJustification.find(params[:id]).localized

    authorize @absence_justification
  end

  def update
    @absence_justification = AbsenceJustification.find(params[:id])
    @absence_justification.assign_attributes resource_params

    authorize @absence_justification

    if @absence_justification.save
      respond_with @absence_justification, location: absence_justifications_path
    else
      render :edit
    end
  end

  def destroy
    @absence_justification = AbsenceJustification.find(params[:id])

    @absence_justification.destroy

    respond_with @absence_justification, location: absence_justifications_path
  end

  def history
    @absence_justification = AbsenceJustification.find(params[:id])

    authorize @absence_justification

    respond_with @absence_justification
  end

  protected

  def resource_params
    params.require(:absence_justification).permit(
      :student_id, :absence_date, :justification
    )
  end
end
