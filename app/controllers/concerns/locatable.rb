module Locatable
  extend ActiveSupport::Concern

  included do
    attr_accessor :location
    before_action :set_location
  end

  def set_location
    @location = supplied_location || ip_location || default_location
  end

  def default_location #lat/lng
    [46.950745, 7.440618] # Berne center
  end

  def ip_location
    if request.location
      loc = request.location.coordinates
      valid_location? loc ? loc : nil
    else
      nil
    end
  end

  def supplied_location
    if params[:location] && params[:location].match(/^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$/)
      params[:location].split(',').map(&:to_f)
    elsif params[:canton]
      canton = params[:canton].upcase.to_sym
      cantons[canton][:location] if cantons.has_key? canton
    else
      nil
    end
  end

  def valid_location?(location)
    location[0] > 0 and location[1] > 0
  end

  def cantons
    {
        AG: { city: 'Aarau',        location: [47.39043, 8.04570] },
        AR: { city: 'Herisau',      location: [47.38570, 9.27985] },
        AI: { city: 'Appenzell',    location: [47.33493, 9.40659] },
        BL: { city: 'Liestal',      location: [47.48661, 7.73343] },
        BS: { city: 'Basel',        location: [47.55960, 7.58858] },
        BE: { city: 'Bern',         location: [46.94797, 7.44745] },
        FR: { city: 'Freiburg',     location: [46.80648, 7.16197] },
        GE: { city: 'Genf',         location: [46.20439, 6.14316] },
        GL: { city: 'Glarus',       location: [47.04043, 9.06721] },
        GR: { city: 'Chur',         location: [46.85078, 9.53199] },
        JU: { city: 'Delsberg',     location: [47.36612, 7.34248] },
        LU: { city: 'Luzern',       location: [47.05017, 8.30931] },
        NE: { city: 'Neuenburg',    location: [48.84837, 8.58800] },
        NW: { city: 'Stans',        location: [46.95719, 8.36597] },
        OW: { city: 'Sarnen',       location: [46.89593, 8.24568] },
        SH: { city: 'Schaffhausen', location: [47.69589, 8.63805] },
        SZ: { city: 'Schwyz',       location: [47.02071, 8.65299] },
        SO: { city: 'Solothurn',    location: [47.20883, 7.53229] },
        SG: { city: 'St.Gallen',    location: [47.42448, 9.37672] },
        TI: { city: 'Bellinzona',   location: [46.19462, 9.02441] },
        TG: { city: 'Frauenfeld',   location: [47.55360, 8.89875] },
        UR: { city: 'Altdorf',      location: [46.88213, 8.64284] },
        VD: { city: 'Lausanne',     location: [46.51965, 6.63227] },
        VS: { city: 'Sitten',       location: [46.23312, 7.36063] },
        ZG: { city: 'Zug',          location: [47.16617, 8.51549] },
        ZH: { city: 'Zürich',       location: [47.37689, 8.54169] }
    }
  end
end

