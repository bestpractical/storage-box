#!/usr/bin/env perl

use lib 'lib';

use Storage::Box;

my ($username,$enterprise_id) = @ARGV;

$enterprise_id ||= '2064336';

my $box = Storage::Box->new(
	key_id => "vmqys6db",
	enterprise_id => $enterprise_id,
	private_key => "/opt/rt4/etc/keys/private_key.pem",
	password => "test",
	client_id => "96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	client_secret => "xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3");

my $id = $box->create_user($username);

print $id, "\n";
