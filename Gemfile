source 'http://rubygems.org'

#ruby '1.9.3'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'
gem 'thin'

# Component requirements
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'haml'
gem 'activerecord', '>= 3.1', :require => 'active_record'
gem 'pg'
gem 'unidecoder'
gem 'rainbow'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.11.3'

gem 'execjs'

group :production do
	gem 'therubyracer', :platform => :ruby
end

group :development do
	gem 'mysql2', '~> 0.3.18'
end

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.11.3'
# end
