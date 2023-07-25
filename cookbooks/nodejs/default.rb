execute 'curl -fsSL https://deb.nodesource.com/setup_20.x | bash -' do
  not_if 'test -e /etc/apt/sources.list.d/nodesource.list'
end

package 'nodejs'
