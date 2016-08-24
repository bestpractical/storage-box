package Storage::Box::Auth;

use Modern::Perl;
use Crypt::JWT;
use Expect;

sub generate_keys {
	my ($password) = @_;
	my $exp = Expect->spawn("openssl genrsa -aes256 -out private_key.pem 2048") 
		or die "Failed to generate private_key.pem";
	$exp->expect(1000,
		[ /private_key\.pem\:/ => sub { $exp->send($password); exp_continue;} ],
		[ /private_key\.pem\:/ => sub { $exp->send($password); exp_continue;} ]
	);
}


1;
