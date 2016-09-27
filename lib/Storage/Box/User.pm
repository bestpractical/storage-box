# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box::User;
use Object::Simple -base;

=pod

=head1 NAME

Storage::Box::User -- manages Box.com App User resources

=head1 SYNOPSIS

    my $user = Storage::Box::User->new(
        auth => $auth,
        name => 'Dave'
    )->create;
  

=head1 DESCRIPTION

This package allows you to manage Box.com App Users.

=cut

use Modern::Perl;
use JSON qw/ encode_json decode_json /;
use Storage::Box::Request;

=pod

=head1 METHODS


=cut

has id => '';
has name => '';
has auth => '';

=pod

B<create()>

    Creates a new App User, requires:

    * name = name of the user
    * auth = an enterprise Storage::Box::Auth object

=cut 

sub create {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/users",
        auth => $self->auth
    );
    $req->content( encode_json({ 
        name => $self->name, 
        is_platform_access_only => JSON::true 
    }));
    $req->post->request;
    if ($req->code == 201) {
        my $json = decode_json($req->body);
        $self->id($json->{id});
    }
    $self;
}

=pod

B<read($enterprise_token,$user_id)>

    Reads the App User metadata for the user

    * id = id of the user
    * auth = an enterprise Storage::Box::Auth object

=cut

sub read {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/users/" . $self->id,
        auth => $self->auth 
    );
    $req->get->request;
    $req->code == 200 ? decode_json($req->body) : {};
}

=pod

B<update(%options)>

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
    my $self = shift;
    my (%options) = @_;
    my @attributes = qw/ name language job_title phone address status timezone space_amount /;
    @data{@attributes} = @options{ @attributes };
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/users/" . $self->id,
        auth => $self->auth
    );
    $req->content( encode_json( \%data ));
    $req->put->request;
    $req->code == 200 ? decode_json($req->body) : {};
}


=pod

B<delete()>

    Deletes the App User specified by the given user_id

=cut

sub delete {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/users/" . $self->id,
        auth => $self->auth
    );
    $req->delete->request;
    $req->code == 204 || $req->code == 404;   # if we don't find it, it has been deleted
}

=pod

=head1 TO DO

stuff

=head1 BUGS

lots

=head1 COPYRIGHT

Copyright (C) 2016 Best Practical Solutions, LLC.

=head1 AUTHORS

Dave Goehrig <dave@dloh.org>

=cut

1;
