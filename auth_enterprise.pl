#!/usr/bin/env perl
#

use lib 'lib';

use Storage::Box::Auth;

my $enterprise_id = $ARGV[0] || '2064336';
print "Authorizing $enterprise_id\n";

my $jwt = Storage::Box::Auth::enterprise(
	"vmqys6db",
	"keys/private_key.pem",
	"test",
	"96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	"$enterprise_id");

my $res =  Storage::Box::Auth::request(
	"96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	"xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3",
	$jwt);

print $res->{access_token}, "\n";
