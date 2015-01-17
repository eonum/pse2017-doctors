class DoctorSerializer < ActiveModel::Serializer
  attributes :id, :title, :name, :address, :phone1, :phone2

  def id
    object.doc_id
  end

  def distance
    object.geo_near_distance
  end
end
