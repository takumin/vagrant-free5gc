# vim: set ft=ruby :

require 'open-uri'
require 'fileutils'

# MItamae Github Release Tag
MITAMAE_VERSION ||= '1.14.0'

MITAMAE_ROLES = [
  :cplane,
  # :uplane,
  # :webconsole,
]

# Download Require Binary
[
  {
    :name => 'mitamae',
    :version => MITAMAE_VERSION,
    :urls => [
      "https://github.com/itamae-kitchen/mitamae/releases/download/v#{MITAMAE_VERSION}/mitamae-x86_64-linux",
    ],
  },
].each do |item|
  base_dir = File.join(File.expand_path('.', __dir__), '.bin', item[:name], item[:version])
  unless File.exist?(base_dir)
    FileUtils.mkdir_p(base_dir, mode: 0755)
  end

  item[:urls].each do |url|
    path = File.join(base_dir, item[:name])
    unless File.exist?(path)
      p "Download: #{url}"
      URI.open(url) do |res|
        IO.copy_stream(res, path)
      end
      FileUtils.chmod(0755, path)
    end
  end
end

# Require Minimum Vagrant Version
Vagrant.require_version '>= 2.3.7'

Vagrant.configure('2') do |config|
  # Require Plugins
  config.vagrant.plugins = ['vagrant-libvirt']

  # Disable SSH Insert Key
  config.ssh.insert_key = false

  # Disable Default Synced Directory
  config.vm.synced_folder '.', '/vagrant',
    disabled: true

  # Mount NFSv4 Synced Directory
  config.vm.synced_folder '.', '/.vagrant',
    nfs_version: '4.2',
    nfs_udp: false

  # Guest Only Networking
  # config.vm.network :private_network,
  #   :libvirt__network_name => 'vagrant-private',
  #   :libvirt__forward_mode => 'none',
  #   :libvirt__dhcp_enabled => false

  # Libvirt Provider Configuration
  config.vm.provider :libvirt do |libvirt|
    # Machine
    libvirt.machine_type = 'q35'
    # CPU
    libvirt.cpu_mode = 'host-passthrough'
    libvirt.cpus = 2
    # Memory
    libvirt.memory = 4096
    # Monitor
    libvirt.graphics_type = 'spice'
    libvirt.video_type = 'qxl'
    # Random
    libvirt.random :model => 'random'
    # TPM
    libvirt.tpm_model = 'tpm-crb'
    libvirt.tpm_type = 'emulator'
    libvirt.tpm_version = '2.0'
    # Storage
    libvirt.storage_pool_name = 'ramdisk'
    # Disk
    libvirt.disk_bus = 'scsi'
    libvirt.disk_controller_model = 'virtio-scsi'
    # Network
    libvirt.management_network_name = 'vagrant-management'
    libvirt.management_network_address = '192.168.121.0/24'
    libvirt.management_network_mode = 'nat'
  end

  # Guest Machine Definitions
  MITAMAE_ROLES.each do |role|
    config.vm.define role do |domain|
      # Hostname
      domain.vm.hostname = "#{role}.vagrant.internal"

      # Ubuntu 20.04 Focal Fossa
      domain.vm.box = 'generic/ubuntu2004'

      # MItamae Install
      domain.vm.provision 'shell' do |shell|
        shell.name   = 'Install mitamae'
        shell.inline = <<~BASH
        if ! mitamae version > /dev/null 2>&1; then
          install -o root -g root -m 0755 /.vagrant/.bin/mitamae/#{MITAMAE_VERSION}/mitamae /usr/local/bin/mitamae
        fi
        BASH
      end

      # MItamae Provision
      domain.vm.provision 'shell' do |shell|
        shell.name   = 'Provision mitamae'
        shell.env = {
          'no_proxy'    => ENV['no_proxy'] || ENV['NO_PROXY'],
          'NO_PROXY'    => ENV['no_proxy'] || ENV['NO_PROXY'],
          'ftp_proxy'   => ENV['ftp_proxy'] || ENV['FTP_PROXY'],
          'FTP_PROXY'   => ENV['ftp_proxy'] || ENV['FTP_PROXY'],
          'http_proxy'  => ENV['http_proxy'] || ENV['HTTP_PROXY'],
          'HTTP_PROXY'  => ENV['http_proxy'] || ENV['HTTP_PROXY'],
          'https_proxy' => ENV['https_proxy'] || ENV['HTTPS_PROXY'],
          'HTTPS_PROXY' => ENV['https_proxy'] || ENV['HTTPS_PROXY'],
        }
        shell.inline = <<~BASH
          cd /.vagrant
          mitamae local roles/#{role}.rb
        BASH
      end
    end
  end
end
