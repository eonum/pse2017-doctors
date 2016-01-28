namespace :density do
  desc 'Calculate hospital densities'
  task hospitals: :environment do
    csv = File.new('data/additional/spitaldichte/fg_27.01.2016_geo_input.csv', 'r')
    out = File.new('data/additional/spitaldichte/hospital_densities.csv', 'w')

    hops = []
    num_cases = {}
    idents = {}
    years = {}

    while line = csv.gets
      vars = line.split ';'
      ident = vars[0]
      year = vars[1]
      impid = vars[2]
      ncas = vars[3].to_i
      name = vars[4]
      bur = vars[5]
      street = vars[6]
      plz = vars[7]
      ort = vars[8]

      hop = Hospital.new
      hop.name = name
      hop.address1 = "#{street}, #{plz} #{ort}"
      # add timeout so Google is happy
      sleep(1)
      location = Geocoder.coordinates(hop.full_address)
      location = Geocoder.coordinates(hop.address2) if location == nil
      location = Geocoder.coordinates(hop.name) if location == nil

      puts "Error: Could not localize #{hop.full_address}" if location == nil
      next if location == nil

      hop.location = [location[1], location[0]]
      hops << hop
      idents[hop.name] = ident
      num_cases[hop.name] = ncas
      years[hop.name] = year
    end

    out.puts "ident;year;nearby_cases_5km;nearby_hospitals_5km;nearby_cases_10km;nearby_hospitals_10km;nearby_cases_20km;nearby_hospitals_20km;coordinate_x;coordinate_y"
    hops.each do |hop|
      ident = idents[hop.name]
      year = years[hop.name]

      out.print "#{ident};#{year};"

      [5,10,20].each do |km|
        num_nearby_cases = 0
        num_nearby_hosptials = 0
        hops.each do |hop2|
          year2 = years[hop2.name]
          next if year != year2

          distance = Geocoder::Calculations.distance_between(hop.location, hop2.location)
          if distance <= km
            num_nearby_cases += num_cases[hop2.name]
            num_nearby_hosptials += 1
          end
        end

        out.print "#{num_nearby_hosptials};#{num_nearby_cases};"
      end

      out.puts "#{hop.location[0]};#{hop.location[1]}"
    end
  end
end
