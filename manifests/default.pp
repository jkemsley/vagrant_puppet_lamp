
exec { 'apt-get update':
  command => 'apt-get update',
  path    => '/usr/bin/',
  timeout => 60,
  tries   => 3,
}

class { 'apt':
  always_apt_update => true,
}

package { ['python-software-properties']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

file { '/home/vagrant/.bash_aliases':
  ensure => 'present',
  source => 'puppet:///modules/puphpet/dot/.bash_aliases',
}

package { ['build-essential', 'vim', 'curl']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

class { 'apache': }

apache::dotconf { 'custom':
  content => 'EnableSendfile Off',
}

apache::module { 'rewrite': }

apache::vhost { 'dev.local':
  server_name   => 'dev.local',
  serveraliases => [],
  docroot       => '/var/www/',
  port          => '80',
  env_variables => [],
  priority      => '1',
}

# apt::ppa { 'ppa:ondrej/php5-experimental':
#   before  => Class['php'],
# }

class { 'php':
  service => 'apache',
  require => Package['apache'],
}

php::module { 'cli': }
php::module { 'curl': }
php::module { 'intl': }
php::module { 'mcrypt': }
php::module { 'mysql': }
php::module { 'gd': }
php::module { 'xmlrpc': }

class { 'php::devel':
  require => Class['php'],
}

class { 'php::pear':
  require => Class['php'],
}

class { 'xdebug':
  service => 'apache',
}

xdebug::config { 'cgi':
  remote_autostart => '0',
  remote_port      => '9000',
}
xdebug::config { 'cli':
  remote_autostart => '0',
  remote_port      => '9000',
}

php::pecl::module { 'xhprof':
  use_package => false,
}

apache::vhost { 'xhprof':
  server_name => 'xhprof',
  docroot     => '/var/www/xhprof/xhprof_html',
  port        => 80,
  priority    => '1',
  require     => Php::Pecl::Module['xhprof']
}


class { 'composer':
  require => Package['php5'],
}

php::ini { 'php':
  value   => ['date.timezone = "America/Chicago"'],
  target  => 'php.ini',
  service => 'apache',
}
php::ini { 'custom':
  value   => ['display_errors = On', 'error_reporting = -1'],
  target  => 'custom.ini',
  service => 'apache',
}

class { 'mysql':
  root_password => 'root',
  require       => Exec['apt-get update'],
}
