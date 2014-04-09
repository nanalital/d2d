require 'unidecoder'
def recruit 
  require 'csv'

  csv = CSV.read './tmp/Recruiters.csv'

  puts
  csv.each_with_index do |cs,i|
    #break if i > 4
    tr = cs[1].to_ascii.gsub(' ','_').gsub(/['`]/,'-').gsub(/\n/,'')+"@greenpeace.org"
    if a = Account.find_by_email(tr) and a.old_id = cs[0].to_i
      puts 'FOUND'
    elsif a = Account.find_by_email(tr) and a.old_id != cs[0].to_i
      #a.old_id = cs[0].to_i
      #a.save
      puts "MISMATCH: #{cs[0]} | #{a.old_id}"
    elsif a = Account.find_by_old_id(cs[0].to_i)
      puts "MISMATCH: #{tr} | #{a.email}"
    else
      puts "CREATED: #{tr}"
      Account.create :name => cs[1], :email => tr+'@greenpeace.org', :role => 'recruiter', :password => 'recruiter', :password_confirmation => 'recruiter', :old_id => cs[0].to_i
    end
  end
end
