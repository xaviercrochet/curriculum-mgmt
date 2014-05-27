class JustificationsController < ApplicationController
  helper JustificationsHelper
  before_action :authenticate_user!
  load_and_authorize_resource
  
  def new
    @student_program = StudentProgram.find(params[:student_program_id])
    @justification = @student_program.build_justification
  end

  def create
    @student_program = StudentProgram.find(params[:student_program_id])
    @justification = @student_program.create_justification(justification_params)
    if @justification.errors.any?
      render action: :new
    else
      @student_program.check
      redirect_to @student_program
    end
  end

  def show
    @justification = Justification.includes(constraint_exceptions: :entity).find(params[:id])
    @answer = Answer.new
  end

  def index
    @justifications = Justification.all
    @answer = Answer.new
  end

  def update
    @justification = Justification.find(params[:id])
    @justification.update(justification_params)
    @justification.update(read: false)
    @justification.check_and_mark_constraint_exceptions
    if @justification.errors.any?
      @student_program = @justification.student_program
      rerdirect_to @justification.student_program
    else
      @justification.student_program.check
      redirect_to @justification.student_program
    end
  end

  def edit
    @justification = Justification.find(params[:id])
    @student_program = @justification.student_program

  end

private

  def justification_params
    params.require(:justification).permit(:student_program_id, :content, constraint_exceptions_attributes: [:id, :message])
  end
end