module DoctorsHelper

  def doctor_address(doctor)
    doctor.address.split(',').map(&:strip).join('<br>').html_safe
  end

end