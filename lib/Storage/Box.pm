# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box;

use Modern::Perl;
use Object::Simple -base;
use Storage::Box::Auth;
use Storage::Box::User;
use Storage::Box::File;
use Storage::Box::Folder;

our $VERSION = '0.01';

=pod 

=encoding utf-8

=head1 NAME

Storage::Box - a module for managing storage at Box.com

=head1 SYNOPSIS

    use Storage::Box;

    my $box = Storage::Box->new(
        key_id => 'lasjfk',
        enterprise_id => '1231923',
        private_key => '/etc/box/keys/private_key.pem'
        password => 'password',
        client_id => '2lkjlkadsjfoiuawer',
        client_secret => 'alksdjfoaiusrnre'
    );

    $box->create_user('bob');

=head1 DESCRIPTION

Storage::Box is 

=head1 METHODS

=cut

has key_id => '';
has enterprise_id => '';
has public_key => '';
has password => '';
has client_id => '';
has client_secret => '';
has user_id => '';
has enterprise_auth => '';
has user_auth => '';
has user => '';

sub authenticate_enterprise {
    my $self = shift;    
    $self->enterprise_auth('') if ($self->enterprise_auth and 
        $self->enterprise_auth->expired);
    unless ($self->enterprise_auth) {
        $self->enterprise_auth( Storage::Box::Auth->new(
            key_id => $self->key_id,
            enterprise_id => $self->enterprise_id,
            private_key => $self->private_key,
            password => $self->password,
            client_id => $self->client_id,
            client_secret => $self->client_secret
        ));
        $self->enterprise_auth->request;
    }
    $self;
}

sub authenticate_user {
    my $self = shift;    
    $self->user_auth('') if ($self->user_auth and 
        $self->user_auth->expired);
    unless($self->user_auth) {
        $self->user_auth( Storage::Box::Auth->new(
            key_id => $self->key_id,
            user_id => $self->user_id,
            private_key => $self->private_key,
            password => $self->password,
            client_id => $self->client_id,
            client_secret => $self->client_secret
        ));
        $self->user_auth->request;
    }
    $self;
}

=pod
B<create_user($self,$name)>

    Creates a new Box.com App user with the given username

=cut

sub create_user {
    my ($self,$name) = @_;
    $self->authenticate_enterprise;
    my $user = Storage::Box::User->new(
        auth => $self->enterprise_auth,
        name => $name
    );
    $user->create;
}

=pod
B<read_user($self,$user_id)>

    Reads a user object for the given user_id

=cut

sub read_user {
    my ($self,$user_id) = @_;
    $self->authenticate_enterprise;
    my $user = Storage::Box::User->new(
        auth => $self->enterprise_auth,
        id => $user_id
    );
    $user->read;
}

=pod
B<update_user($self,$user_id,%options)>

    Updates a user object specified by user_id with the given hash 
    of key => values. Returns the updated user object.

=cut

sub update_user {
    my ($self,$user_id,%options) = @_;
    $self->authenticate_enterprise;
    my $user = Storage::Box::User->new(
        auth => $self->enterprise_auth,
        id => $user_id
    );
    $user->update(%options);
}

=pod
B<delete_user($self,$user_id)>

    Deletes the user associated with $user_id.  Returns true on success.
=cut

sub delete_user {
    my ($self,$user_id) = @_;
    $self->authenticate_enterprise;
    my $user = Storage::Box::User->new(
        auth => $self->enterprise_auth,
        id => $user_id
    );
    $user->delete;
}

=pod
B<create_file($self,$filename)>

=cut

sub create_file {
    my ($self,$filename) = @_;
    $self->authenticate_user;
    my $file = Storage::Box::File->new(
        auth => $self->user_auth,
        name => $filename
    );
    $file->create;
    $file;
}

sub download_file {
    my ($self,$file_id) = @_;
    $self->authenticate_user;
    my $file = Storage::Box::File->new(
        auth => $self->user_auth,
        id => $file_id
    );
    $file->download;
}

sub delete_file {
    my ($self,$file_id) = @_;
    $self->authenticate_user;
    my $file = Storage::Box::File->new(
        auth => $self->user_auth,
        id => $file_id
    );
    $file->delete;
}

sub create_folder {
    my ($self,$name) = @_;
    $self->authenticate_user;
    my $folder = Storage::Box::Folder->new(
        auth => $self->user_auth,
        name => $name
    );
    $folder->create;
}

sub list_folder {
    my ($self,$folder_id) = @_;
    $self->authenticate_user;
    my $folder = Storage::Box::Folder->new(
        auth => $self->user_auth,
        folder_id => $folder_id
    );
    $folder->items;
}

sub delete_folder {
    my ($self,$folder_id) = @_;
    $self->authenticate_user;
    my $folder = Storage::Box::Folder->new(
        auth => $self->user_auth,
        folder_id => $folder_id
    );
    $folder->delete;
}

=pod

=head1 AUTHOR

Dave Goehrig E<lt>dave@dloh.orgE<gt>

=head1 COPYRIGHT

Copyright 2016- Dave Goehrig

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;


