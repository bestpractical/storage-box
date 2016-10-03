use inc::Module::Install;

name 'Storage-Box';
all_from 'lib/Storage/Box.pm';
readme_from 'lib/Storage/Box.pm';

requires 'Object::Simple' => '3.1702';
requires 'Modern::Perl' => '1.20150127';
requires 'Crypt::JWT' => '0.017';
requires 'Expect' => '1.15';
requires 'Data::UUID' => '1.221';
requires 'JSON' => '2.90';
requires 'WWW::Curl' => '4.17';

WriteAll;
