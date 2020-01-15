config = {
  local: './vagrant/config/vagrant-local.yml',
  example: './vagrant/config/vagrant-local.example.yml'
}
options = YAML.load_file config[:example]

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.define "Yii3Demo" do |t|

  config.vm.synced_folder './', '/app', owner: 'vagrant', group: 'vagrant'
  config.vm.network "forwarded_port", guest: 5432, host: 5432, host_ip:"127.0.0.1"
end

config.vm.provider "virtualbox" do |v|
    v.name = "Yii3Demo"
end

config.vm.network "private_network", ip: "192.168.2.10"
   config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
end
  # provisioners
  config.vm.provision 'shell', path: './vagrant/provision/once-as-root.sh', args: [options['timezone']]
  config.vm.provision 'shell', path: './vagrant/provision/once-as-vagrant.sh', args: [options['github_token']], privileged: false
  config.vm.provision 'shell', path: './vagrant/provision/always-as-root.sh', run: 'always'
end
