requires 'perl', '5.008005';

requires 'Modern::Perl', '1.20150127';
requires 'Crypt::JWT', '0.017';
requires 'Expect', '1.15';
requires 'Data::UUID', '1.221';
requires 'JSON', '2.90';
requires 'WWW::Curl', '4.17';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Pod';
};
