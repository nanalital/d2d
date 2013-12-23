require 'unidecoder'
require 'csv'

def recruit 
  csv = File.readlines './tmp/Recruiters.csv'

  csv.each do |c|
    cs = c.split(',')
    ci = cs[3]
    cit = City.find_by_name ci
    unless ci == 'sCity'
      if cit
        puts cit.name + ' ' + cit.id.to_s
        city = cit.id
      else
        unless ci == ''
          puts ci + ' ' + 'creating'.foreground(:red)
          cit = City.create :name => ci
          city = cit.id
        else
          city = nil
        end
      end
      tr = cs[2].to_ascii.gsub(' ','_').gsub(/['`]/,'-')
      Account.create :name => cs[2], :email => tr+'@greenpeace.org', :stype => cs[1], :city_id => city, :role => 'recruiter', :password => 'recruiter', :password_confirmation => 'recruiter', :old_id => cs[0].to_i
    end
  end
end
