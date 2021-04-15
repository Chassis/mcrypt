# Mcrypt Chassis Extension.
A Chassis extension to install and configure
[Mcrypt](http://php.net/manual/en/book.mcrypt.php) on your server.

## Usage
1. Add this extension to your extensions directory. `git clone git@github.com:Chassis/mcrypt.git extensions/mcrypt`
2. Run `vagrant provision`
3. Mcrypt has been installed on your Chassis VM!

That's it!

## Mcrypt Version

If you encounter problems when provisioning it might be related to the PHP version you are using. The Mcrypt package version defaults to 1.0.4 but you can modify this in your Chassis config like so:

```yaml
mcrypt: 1.0.2
```
