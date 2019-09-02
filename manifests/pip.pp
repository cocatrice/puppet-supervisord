# Class: supervisord::pip
#
# Optional class to install setuptool and pip
#
class supervisord::pip inherits supervisord {

  Exec {
    path => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  if ! defined(Package['curl']) {
    ensure_packages('curl')
  }

  exec { 'install_setuptools':
    command => "curl ${supervisord::setuptools_url} | python",
    cwd     => '/tmp',
    require => Package['curl'],
    unless  => 'which easy_install && easy_install --version | grep setuptools',
  }

  exec { 'install_pip':
    command => 'easy_install pip',
    require => Exec['install_setuptools'],
    unless  => 'which pip',
  }

  # See https://github.com/pypa/setuptools/issues/581
  exec { 'upgrade_pip':
    command => 'pip install --upgrade pip',
    onlyif  => 'pip list 2>&1 | grep "You should consider upgrading"',
    require => Exec['install_pip'],
  }

  exec { 'upgrade_setuptools':
    command     => 'pip install --upgrade setuptools || pip list | grep "setuptools"',
    environment => ['LC_ALL=C'],
    onlyif      => 'pip list | grep "setuptools" | grep "33.1.1" || ! pip list | grep "setuptools"',
    require     => Exec['upgrade_pip'],
  }

  if $::osfamily == 'RedHat' {
    exec { 'pip_provider_name_fix':
      command   => 'alternatives --install /usr/bin/pip-python pip-python /usr/bin/pip 1',
      subscribe => Exec['install_pip'],
      unless    => 'which pip-python',
    }
  }

}
