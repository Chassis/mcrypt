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
	$mcrypt_version = $config[mcrypt]

	if versioncmp( $php, '5.4' ) <= 0 {
		$php_package = 'php5'
	}
	else {
		$php_package = "php${$php}"
	}

	# Mcyrpt isn't shipped in PHP 7.2 anymore but occasionally developers might need to still use it locally.
	if versioncmp( $php, '5.4' ) >= 0 and versioncmp( $php, '7.2' ) >= 0 {
		ensure_packages( [ "${php_package}-dev" ], {
			ensure  => $package,
			require => [
				Apt::Ppa['ppa:ondrej/php'],
				Class['apt::update'],
			],
		} )

		ensure_packages( [ 'libmcrypt-dev' ], {
			ensure  => $package,
			require => Package["${php_package}-dev"]
		} )

		ensure_packages( [ 'php-pear' ], {
			ensure  => latest,
			require => [
				Package["${php_package}-dev"],
				Package["${php_package}-xml"],
			],
		} )

		ensure_resource( 'exec', 'pecl channel-update pecl.php.net', {
			path    => '/usr/bin',
			require => [
				Package['php-pear'],
				Package["${php_package}-dev"],
				Package["${php_package}-xml"],
			],
		} )

		exec { 'pecl install mcrypt for PHP 7.2+':
			path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
			command => "pecl install mcrypt-${mcrypt_version}",
			require => [
				Package['php-pear'],
				Package["${php_package}-dev"],
				Exec['pecl channel-update pecl.php.net'],
			],
			unless  => "pecl info mcrypt-${mcrypt_version}",
		}

		file { "/etc/php/${php}/cli/conf.d/mcrypt.ini":
			ensure  => $file,
			content => template('mcrypt/mcrypt.ini.erb'),
			notify  => Service["${$php_package}-fpm"],
			require => [
				Exec[ 'pecl install mcrypt for PHP 7.2+' ],
				Package["${php_package}-cli"],
			],
		}

		file { "/etc/php/${php}/fpm/conf.d/mcrypt.ini":
			ensure  => $file,
			content => template('mcrypt/mcrypt.ini.erb'),
			notify  => Service["${$php_package}-fpm"],
			require => [
				Exec[ 'pecl install mcrypt for PHP 7.2+' ],
				Package["${php_package}-fpm"],
			],
		}

	} else {
		package { "${$php_package}-mcrypt":
		  ensure  => $package,
		  require => Package["${$php_package}-fpm"],
		  notify  => Service["${$php_package}-fpm"]
		}
	}
}
