execute 'curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg' do
  not_if 'test -e /usr/share/keyrings/yarn.gpg'
end

file '/etc/apt/sources.list.d/yarn.list' do
  owner 'root'
  group 'root'
  mode '0644'
  content 'deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main'
  notifies :run, 'execute[apt-get update]', :immediately
end

execute 'apt-get update' do
  action :nothing
end

package 'yarn'
