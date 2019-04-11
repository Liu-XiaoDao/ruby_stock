source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'terminal-table', '~> 1.8'
