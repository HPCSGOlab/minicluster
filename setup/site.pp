# Include the sudo class.
include sudo

class common_config {

  group { 'demo':
    ensure => 'present',
  }

  user { 'demo':
    ensure     => 'present',
    comment    => 'Demo User',
    home       => '/home/demo',
    managehome => true,
    shell => "/bin/bash",
    password   => pw_hash('tinytitan93', 'SHA-512', 'mysalt'),
    groups     => ['demo', 'adm', 'cdrom', 'sudo', 'audio', 'dip', 'video', 'plugdev', 'render', 'i2c', 'lpadmin', 'gdm', 'sambashare', 'weston-launch', 'gpio'],
    require    => Group['demo']
  }

  package { ['git', 'build-essential', 'libopenmpi-dev', 'libgl1-mesa-dev', 'python3', 'python3-pip', 'python3-dev', 'libglew-dev', 'glew-utils', 'htop', 'libglfw3-dev', 'libxxf86vm-dev', 'libxi-dev', 'xorg-dev']:
    ensure => 'installed',
  }

  ssh_authorized_key { 't.allen@uncc.edu':
    ensure => present,
    user   => 'demo',
    type   => 'ssh-ed25519',
    key    => 'AAAAC3NzaC1lZDI1NTE5AAAAIAFxXa8PQ8GneMqIsy/mzEBvUBXD28xWit/uz7Q/0YSN',
    require => User['demo'],
  }

  file { '/home/demo/.ssh/id_ed25519':
    ensure => 'file',
    source => 'puppet:///modules/demokeys/id_ed25519',
    owner  => 'demo',
    group  => 'demo',
    mode   => '0600',
    require => User['demo'],
  }
  file { '/home/demo/.ssh/id_ed25519.pub':
    ensure => 'file',
    source => 'puppet:///modules/demokeys/id_ed25519.pub',
    owner  => 'demo',
    group  => 'demo',
    mode   => '0644',
    require => User['demo'],
  }

  $nodes = ['0', '1', '2', '3', '4', '5', '6', '7', '8']

  $nodes.each |String $node| {
    $hostname = "demo0${node}"
    $ip_address = "192.168.0.1${node}"
    $aliases = ["${hostname}.uncc.edu", "${hostname}.charlotte.edu"]

    host { $hostname:
      ip           => $ip_address,
      host_aliases => $aliases,
      ensure       => present,
      comment      => "This is node ${hostname}",
      provider     => 'parsed',
    }
  }


  #Set up passwordless sudo for the demo user.
  sudo::conf { 'demo':
    content => 'demo ALL=(ALL) NOPASSWD:ALL',
    require => User['demo'],
  }


}

node 'demo00', 'demo00.charlotte.edu', 'demo00.uncc.edu' {
  include common_config
  #Set up passwordless sudo for the demo user.
  sudo::conf { 'tallen':
    content => 'tallen ALL=(ALL) NOPASSWD:ALL',
  }
}

node 'demo01', 'demo01.charlotte.edu', 'demo01.uncc.edu' {

  include common_config
}

node 'demo02', 'demo02.charlotte.edu', 'demo02.uncc.edu' {
  include common_config
}

node 'demo03', 'demo03.charlotte.edu', 'demo03.uncc.edu' {
  include common_config
}

node 'demo04', 'demo04.charlotte.edu', 'demo04.uncc.edu' {
  include common_config
}

node 'demo05', 'demo05.charlotte.edu', 'demo05.uncc.edu' {
  include common_config
}

node 'demo06', 'demo06.charlotte.edu', 'demo06.uncc.edu' {
  include common_config
}

node 'demo07', 'demo07.charlotte.edu', 'demo07.uncc.edu' {
  include common_config
}

node 'demo08', 'demo08.charlotte.edu', 'demo08.uncc.edu' {
  include common_config
}

