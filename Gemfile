source 'https://rubygems.org'

ruby '2.3.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
gem 'pg'
gem 'thin'

# front-end
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'sass-rails', '~> 5.0'
gem 'simple_form'
gem 'slim-rails'
gem 'uglifier', '>= 1.3.0'
gem 'httparty', '0.13.5'
gem 'unirest'
gem 'gruff'

# tools
gem 'devise'
gem 'figaro'

group :development, :test do
  gem 'pry'
end

group :development do
  gem 'listen'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
