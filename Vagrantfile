NUMBER_OF_CONTROL_NODES ||= 3
NUMBER_OF_COMPUTE_NODES ||= 2
NUMBER_OF_STORAGE_NODES ||= 3
NUMBER_OF_NETWORK_NODES ||= 2
NUMBER_OF_MONITOR_NODES ||= 1

NODE_SETTINGS ||= {
  control: {
    cpus: 8,
    memory: 1024 * 16,
    ip_starts_with: 2
  },
  compute: {
    cpus: 4,
    memory: 1024 * 8,
    ip_starts_with: 3
  },
  storage: {
    cpus: 4,
    memory: 1024 * 2,
    ip_starts_with: 4
  },
  network: {
    cpus: 2,
    memory: 1024 * 2,
    ip_starts_with: 5
  },
  monitor: {
    cpus: 2,
    memory: 1024 * 2,
    ip_starts_with: 6
  },
}

vagrant_dir = File.expand_path(File.dirname(__FILE__))

unless File.file?(File.join(vagrant_dir, 'vagrantkey'))
  system("ssh-keygen -f #{File.join(vagrant_dir, 'vagrantkey')} -N '' -C this-is-vagrant")
end

def get_setting(node, setting)
  NODE_SETTINGS[node][setting]
rescue
  raise VagrantConfigMissing,
    "Missing configuration for NODE_SETTINGS[#{node}][#{setting}]"
end

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"

  username = "vagrant"
  user_home = "/home/#{username}"
  my_privatekey = File.read(File.join(vagrant_dir, "vagrantkey"))
  my_publickey = File.read(File.join(vagrant_dir, "vagrantkey.pub"))

  config.vm.provision :shell, inline: <<-EOS
    mkdir -p /root/.ssh
    echo '#{my_privatekey}' > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    echo '#{my_publickey}' > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo '#{my_publickey}' > /root/.ssh/id_rsa.pub
    chmod 644 /root/.ssh/id_rsa.pub
    mkdir -p #{user_home}/.ssh
    echo '#{my_privatekey}' >> #{user_home}/.ssh/id_rsa
    echo '#{my_publickey}' >> #{user_home}/.ssh/authorized_keys
    chmod 600 #{user_home}/.ssh/*
    echo 'Host *' > #{user_home}/.ssh/config
    echo StrictHostKeyChecking no >> #{user_home}/.ssh/config
    chown -R #{username} #{user_home}/.ssh
  EOS

  ['compute', 'storage', 'network', 'control', 'monitor'].each do |node_type|
    (1..self.class.const_get("NUMBER_OF_#{node_type.upcase}_NODES")).each do |i|
      hostname = "#{node_type}#{i}"
      ip_starts_with = get_setting(node_type.to_sym, :ip_starts_with)
      config.vm.define hostname do |node|
        node.vm.hostname = "#{hostname}"
        node.vm.network "private_network", libvirt__network_name: "network", ip: "192.168.126.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "api", ip: "192.168.127.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "external", ip: "192.168.128.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "storage", ip: "192.168.129.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "cluster", ip: "192.168.130.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "tunnel", ip: "192.168.131.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "dns", ip: "192.168.132.#{ip_starts_with}#{i}"
        node.vm.network "private_network", libvirt__network_name: "octavia", ip: "192.168.133.#{ip_starts_with}#{i}"
        node.vm.provider :libvirt do |vm|
          if "#{node_type}" == "storage"
            vm.storage :file, :size => '100G'
            vm.storage :file, :size => '100G'
            vm.storage :file, :size => '100G'
          end
          vm.nested = true
          vm.memory = get_setting(node_type.to_sym, :memory)
          vm.cpus = get_setting(node_type.to_sym, :cpus)
        end
      end
    end
  end
end
