#!/usr/bin/env perl
#

use lib 'lib';

use Storage::Box::Auth;
use Data::Dumper;

print "Authorizing $ARGV[0]\n";

my $jwt = Storage::Box::Auth::user(
	"vmqys6db",
	"keys/private_key.pem",
	"test",
	"96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	"$ARGV[0]");

my $res =  Storage::Box::Auth::request(
	"96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	"xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3",
	$jwt);

print $res->{access_token}, "\n";
