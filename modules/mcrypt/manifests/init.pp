# A Chassis extensions to add mcrypt to your Chassis server
class mcrypt (
	$config,
	$path = '/vagrant/extensions/mcrypt'
) {
	if ( ! empty( $::config[disabled_extensions] ) and 'chassis/mcrypt' in $config[disabled_extensions] ) {
		$package = absent
		$file = absent
	} else {
		$package = latest
		$file = present
	}

	$php = $config[php]

	if versioncmp( $php, '5.4') <= 0 {
		$php_package = 'php5'
	}
	else {
		$php_package = "php${$php}"
	}

	# Mcyrpt isn't shipped in PHP 7.2 anymore but occasionally developers might need to still use it locally.
	if versioncmp( $php, '5.4' ) >= 0 and versioncmp( $php, '7.2' ) >= 0 {
		if ! defined( Package["php${config[php]}-dev"] ) {
			package { "php${config[php]}-dev":
				ensure  => $package,
				require => Package["php${config[php]}-fpm"]
			}
		}

		if ! defined( Package['libmcrypt-dev'] ) {
			package { 'libmcrypt-dev':
				ensure  => $package,
				require => Package["php${config[php]}-dev"]
			}
		}

		if ! defined( Package['php-pear'] ) {
			package { 'php-pear':
			  ensure => installed,
			}
		}

		if ! defined( Exec['pecl channel-update pecl.php.net'] ) {
			exec { 'pecl channel-update pecl.php.net':
				path    => '/usr/bin',
				require => [
					Package['php-pear'],
					Package["${php_package}-xml"],
					Package["${php_package}-dev"],
				]
			}
		}

		exec { 'pecl install mcrypt for PHP 7.2+':
			path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
			command => 'pecl install mcrypt-1.0.2',
			require => [
				Package['php-pear'],
				Package["php${config[php]}-dev"],
				Exec['pecl channel-update pecl.php.net'],
			],
			unless  => 'pecl info mcrypt-1.0.2',
		}

		file { "/etc/php/${php}/cli/conf.d/mcrypt.ini":
			ensure  => $file,
			content => template('mcrypt/mcrypt.ini.erb'),
			notify  => Service["${$php_package}-fpm"],
			require => Exec[ 'pecl install mcrypt for PHP 7.2+' ],
		}

		file { "/etc/php/${php}/fpm/conf.d/mcrypt.ini":
			ensure  => $file,
			content => template('mcrypt/mcrypt.ini.erb'),
			notify  => Service["${$php_package}-fpm"],
			require => Exec[ 'pecl install mcrypt for PHP 7.2+' ],
		}

	} else {
		package { "${$php_package}-mcrypt":
		  ensure  => $package,
		  require => Package["${$php_package}-fpm"],
		  notify  => Service["${$php_package}-fpm"]
		}
	}
}
