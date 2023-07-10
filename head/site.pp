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

node 'demo00' {
  include common_config
}

node 'demo01' {

  include common_config
}

node 'demo02' {
  include common_config
}

node 'demo03' {
  include common_config
}

node 'demo04' {
  include common_config
}

node 'demo05' {
  include common_config
}

node 'demo06' {
  include common_config
}

node 'demo07' {
  include common_config
}

node 'demo08' {
  include common_config
}

