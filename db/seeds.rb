# coding: utf-8

email     = '@greenpeace.org'
password  = 'supp0rter'
name      = 'Tomer'
surname   = 'Greenpeace'

admin = false
user = false
accounts = Account.all

accounts.each do |acc|
  if acc.role == 'admin' then admin = true end
  if acc.role == 'user' then user = true end
end

unless admin
  if accounts == []
    account = Account.create(:email => 'tomer.harpaz'+email, :name => name, :surname => 'Admin', :password => password, :password_confirmation => password, :role => "admin")
    if account.valid?
      shell.say "================================================================="
      shell.say "Account has been successfully created, now you can login with:"
      shell.say "================================================================="
      shell.say "   email: admin#{email}"
      shell.say "   password: #{password}"
      shell.say "================================================================="
    else
      shell.say "Sorry but something went wrong!"
      shell.say ""
      account.errors.full_messages.each { |m| shell.say "   - #{m}" }
    end
  else
    adm = Account.first
    adm.password = password
    adm.password_confirmation = password
    adm.role = 'admin'
    if adm.save
      shell.say "================================================================="
      shell.say "Account has been successfully modified, now you can login with:"
      shell.say "================================================================="
      shell.say "   email: #{adm.email}"
      shell.say "   password: #{password}"
      shell.say "================================================================="
    end
  end
end

cities = {
'תל-אביב' => ['כיכר ציון','תחנה מרכזית ירושלים','שוק מחנה יהודה','רחבת המשביר ירושלים','דוידקה ירושלים','המושבה הגרמנית ירושלים','יפו -ירושלים','ירושלים כללי','רכבת ההגנה','בורסה רמת גן','תחנה מרכזית חדשה ת"א','רכבת מרכז ת"א','עזריאלי','גן העיר','דיזינגוף סנטר','אוניברסיטת ת"א','נחלת בנימין ת"א','סנימטק תל אביב','תל אביב כללי'],
'ירושלים' => ['כיכר ציון','תחנה מרכזית ירושלים','שוק מחנה יהודה','רחבת המשביר ירושלים','דוידקה ירושלים','המושבה הגרמנית ירושלים','יפו -ירושלים','ירושלים כללי'],
'חיפה' => ['מרכז הכרמל','גרנד קניון','מרכז חורב','לב המפרץ','חוף הכרמל','מרכז זיו','חוצות המפרץ','אוניברסיטת חיפה','הדר','קריית הממשלה','חיפה כללי','קרית אתא']
}

unless user
  Account.create(:email => 'dd'+email, :name => name, :surname => 'User', :password => password, :password_confirmation => password, :role => "user")
end

cities.each do |k,v|
  c = City.new
  c.name = k
  c.save
  c.other_id = c.id
  c.save
  v.each do |o|
    l = Location.new
    l.name = o
    l.save
    l.other_id = l.id
    l.save
    c.locations << l
  end
end


