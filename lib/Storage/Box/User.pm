# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box::User;

=pod

=head1 NAME

Storage::Box::User -- manages Box.com App User resources

=head1 SYNOPSIS

  my $user = Storage::Box::User::create($enterprise_token,$name)
  

=head1 DESCRIPTION

This package allows you to manage Box.com App Users.

=cut

use Modern::Perl;
use HTTP::Request;
use LWP::UserAgent;
use JSON qw/ encode_json decode_json /;
use Data::Dumper;

=pod

=head1 METHODS

B<create($enterprise_token,$username)>

  Creates a new App User, requires an enterprise OAuth token

=cut 

sub create {
    my ($token,$username) = @_;
    my $request = HTTP::Request->new( POST => "https://api.box.com/2.0/users" );
    $request->header( Authorization => "Bearer $token" );
    $request->content( encode_json({ name => $username, is_platform_access_only => JSON::true }));
    my $response = LWP::UserAgent->new->request($request);
    decode_json($response->content) if $response->code == 201; 
}

=pod

B<read($enterprise_token,$user_id)>

    Reads the App User metadata for the given user_id

=cut

sub read {
    my ($token,$id) = @_;
    my $request = HTTP::Request->new( GET => "https://api.box.com/2.0/users/$id" );
    $request->header( Authorization => "Bearer $token" );
    my $response = LWP::UserAgent->new->request($request);
    decode_json($response->content) if $response->code == 200;
}

=pod

B<update($enterprise_token,$user_id,$options)>

    Updates the App User resource for the updateable fields only.

    * $enterprise_token = OAuth2 token for the enterprise
    * $user_id = id of the user resource to update
    * $options = a hashref containing the fields to update:
        * name
        * language
        * job_title
        * phone
        * address
        * status
        * timezone
        * space_ammount

=cut

sub update {
    my %data = ();
    my ($token,$id,$options) = @_;
    my @attributes = qw/ name language job_title phone address status timezone space_amount /;
    @data{@attributes} = @$options{ @attributes };
    my $request = HTTP::Request->new( PUT => "https://api.box.com/2.0/users/$id" );
    $request->header( Authorization => "Bearer $token" );
    $request->content( encode_json( \%data ));
    my $response = LWP::UserAgent->new->request($request);
    decode_json($response->content) if $response->code == 200 || $response->code == 204;
}


=pod

B<delete($enterprise_token,$user_id)>

    Deletes the App User specified by the given user_id

=cut

sub delete {
    my ($token,$id) = @_;
    my $request = HTTP::Request->new( DELETE => "https://api.box.com/2.0/users/$id" );
    $request->header( Authorization => "Bearer $token" );
    my $response = LWP::UserAgent->new->request($request);
    $response->code == 204 || $response->code == 404;   # if we don't find it, it has been deleted
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
