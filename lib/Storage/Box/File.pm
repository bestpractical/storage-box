# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box::File;

=pod

=head1 NAME

Storage::Box::File -- manages Box.com File resources

=head1 SYNOPSIS

  my $file = Storage::Box::File::create($user_token,$name,$parent,$data)
  

=head1 DESCRIPTION

This package allows you to manage Box.com Files.

=cut

use Modern::Perl;
use HTTP::Request;
use LWP::UserAgent;
use JSON qw/ encode_json decode_json /;
use Data::Dumper;

=pod

=head1 METHODS

B<create($user_token,$name,$parent,$data)>

  Creates a new File with the given name in the specified parent Folder.

=cut 

sub create {
    my ($token,$name,$parent,$data) = @_;
    my $request = HTTP::Request->new( POST => "https://api.box.com/2.0/files/content" );
    $request->header( Authorization => "Bearer $token" );
    $request->content <<THERE;
attributes='{"name":"$name","parent":{"id":"$parent"}}'&
THERE

    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($request);
    print Dumper $response;
    decode_json($response->content); 
}

=pod

=head1 TO DO

stuff

=head1 BUGS

lots

=head1 COPYRIGHT

Best Practical LLC.

=head1 AUTHORS

Dave Goehrig <dave@dloh.org>

=cut

1;
