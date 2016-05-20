namespace :comparisons do

  desc 'Add Icons to the comparisons'
  task add_icons: :environment do


    Comparison.where(:name_de => 'Kardiologie').update_all(:image_link => 'heartrate.png')

    Comparison.where(:name_de => 'Geburten').update_all(:image_link => 'baby.png')

    Comparison.where(:name_de => 'Übersicht').update_all(:raw_html_icon => '<i class="fa fa-list" style="color: black; font-size: 30px"></i>')

    Comparison.where(:name_de => 'Bewegungsapparat / Orthopädie: Hüfte').update_all(:image_link => 'wheelchair.png')

    Comparison.where(:name_de => 'Bewegungsapparat / Orthopädie: Knie').update_all(:raw_html_icon => '<i class="fa fa-medkit" style="color: black; font-size: 30px"></i>')

    Comparison.where(:name_de => 'Ausstattung der Akutspitäler').update_all(:image_link => 'syringe.png')

    Comparison.where(:name_de => 'Psychiatrie (überregional)').update_all(:image_link => 'psychiatry.png')

  end


end


