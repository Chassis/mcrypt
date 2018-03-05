# A Chassis extensions to add mcrypt to your Chassis server
class mcrypt (
	$config,
	$path = '/vagrant/extensions/mcrypt'
) {

	$php = $config[php]

	if versioncmp( $php, '5.4') <= 0 {
		$php_package = 'php5'
	}
	else {
		$php_package = "php${$php}"
	}

	package { "${$php_package}-mcrypt":
		ensure  => latest,
		require => Package["${$php_package}-fpm"],
		notify  => Service["${$php_package}-fpm"]
	}
}
