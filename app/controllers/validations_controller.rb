class ValidationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  def index
    @validations = Validation.all
  end

  def show
    @validation = Validation.find(params[:validation_id])
  end

  def destroy
    @validation = Validation.find(params[:id])
    @validation.destroy
    redirect_to validations_path
  end

  def validate
    @validation = Validation.find(params[:validation_id])
    @validation.student_program.validate
    @validation.destroy
    redirect_to validations_path
  end

private
  def record_history
    session[:history] ||= []
    session[:history].push request.url
    session[:history] = session[:history].last(10)
  end

  def back
    session[:history].pop unless session.nil?
    root_path if session.nil?
  end
end
