requires 'perl', '5.008005';

requires 'Modern::Perl', '1.20150127';
requires 'Crypt::JWT', '0.017';
requires 'Expect', '1.15';
requires 'Data::UUID', '1.221';
requires 'HTTP::Request', '6.11';
requires 'Crypt::OpenSSL::RSA', '0.28';
requires 'Crypt::PK::RSA';

on test => sub {
    requires 'Test::More', '0.96';
};
