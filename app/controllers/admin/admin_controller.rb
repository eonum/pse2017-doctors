class Admin::AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_only, :except => :get_doctor_path



  def admin_only
    unless current_user.is_admin?
      unless request.env['PATH_INFO'].include? get_doctor_path
        redirect_to get_doctor_path
      end
    end
  end

  def get_doctor_path
    unless current_user.is_admin?
      email = current_user.email

      return admin_doctors_path + "/" + email.split("@")[0]
    end
  end

  layout 'admin'

end