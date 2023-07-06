class common_config {

  user { 'demo':
    ensure     => 'present',
    comment    => 'Demo User',
    home       => '/home/demo',
    managehome => true,
    password   => sha512crypt('tinytitan93', 'salt'),
    groups     => ['sudo', 'users'],
  }

  package { ['git', 'build-essential', 'libopenmpi-dev', 'libgl1-mesa-dev', 'python3', 'python3-pip', 'python3-dev']:
    ensure => 'installed',
  }
}

node 'ubuntu-node-1' {

  include common_config
}

node 'ubuntu-node-2' {
  include common_config
}

