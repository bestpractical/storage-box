# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box;

use Modern::Perl;
use Object::Simple -base;
use Storage::Box::Auth;
use Storage::Box::User;
use Storage::Box::File;
use Storage::Box::Folder;
use Storage::Box::Logger;

our $VERSION = '0.03';
our $logger = Storage::Box::Logger::logger;

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

Storage::Box is module for interfacing with Box.com's REST API.
It provides a JWT authenticated cleint for a server side application.



=head1 METHODS

=cut

has key_id => '';
has enterprise_id => '';
has public_key => '';
has private_key => '';
has password => '';
has client_id => '';
has client_secret => '';
has user_id => '';
has enterprise_auth => '';
has user_auth => '';
has user => '';
has logger => '';

=pod

B<authenticate_enterprise($self)>

    Attempts to authenticate an enterprise access token,
    and requires the following parameters be set:

        * key_id
        * enterprise_id
        * private_key
        * password
        * client_id
        * client_secret

    If successful the 'enterprise_auth' parameter will be
    set to a Storage::Box::Auth object with a suitable
    token.  These tokens are generally good for 1 hour, and
    will attempt to reprovision automatically when expired.

=cut

sub authenticate_enterprise {
    my $self = shift;    
    $self->enterprise_auth('') if ($self->enterprise_auth and 
        $self->enterprise_auth->expired);
     if ($self->enterprise_auth eq '') {
        $self->enterprise_auth( Storage::Box::Auth->new(
            key_id => $self->key_id,
            enterprise_id => $self->enterprise_id,
            private_key => $self->private_key,
            password => $self->password,
            client_id => $self->client_id,
            client_secret => $self->client_secret
        ));
        my $req = $self->enterprise_auth->enterprise->request;
        $logger->error("Failed to authenticate " . $self->enterprise_id . " with code " . $req->code . "\n") 
            unless $req->code == 200;
    }
    $self;
}

=pod

B<authenticate_user($self)>

    Attempts to authenticate a user access token.
    Requires the following parameters be populated:

        * key_id
        * user_id
        * private_key
        * password
        * client_id
        * client_secret

    A user_id can be obtained by using the enterprise_auth
    to create a new app user via create_user.  This
    user_id can then be used to inteface with files and
    folders.  The user auth token usually lasts for
    about 1 hour, and will try to auto reprovision when
    expired.

=cut

sub authenticate_user {
    my $self = shift;    
    $self->user_auth('') if ($self->user_auth and 
        $self->user_auth->expired);
    if ($self->user_auth eq '') {
        $self->user_auth( Storage::Box::Auth->new(
            key_id => $self->key_id,
            user_id => $self->user_id,
            private_key => $self->private_key,
            password => $self->password,
            client_id => $self->client_id,
            client_secret => $self->client_secret
        ));
        my $req = $self->user_auth->user->request;
        $logger->error("Failed to authenticate user $self->user_id, with code $req->code\n")
            unless $req->code == 200;
    }
    $self;
}

=pod

B<create_user($self,$name)>

    Creates a new Box.com App user with the given username.
    If successful it will set the user object's id to the
    user's user_id.

=cut

sub create_user {
    my ($self,$name) = @_;
    $self->authenticate_enterprise;
    my $user = Storage::Box::User->new(
        auth => $self->enterprise_auth,
        name => $name
    );
    $user->create();
    $user->id;
}

=pod

B<read_user($self,$user_id)>

    Reads a user object for the given user_id,
    returns a hash with the user's data.
    On failure it will return an empty hash.

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
    of key => values. Returns the updated user hash.

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

    Uploads the file specified by filename,
    and returns the file object.  If the 
    file is successfully uploaded the id 
    of the file object willl be set.

=cut

sub create_file {
    my ($self,$filename) = @_;
    $self->authenticate_user;
    my $file = Storage::Box::File->new(
        auth => $self->user_auth,
        name => $filename
    );
    $file->create;
    $file->id;
}

=pod

B<download_file($self,$file_id)>

    Returns the contents of the file specified by file_id,
    or an empty string if it fails.

=cut

sub download_file {
    my ($self,$file_id) = @_;
    $self->authenticate_user;
    my $file = Storage::Box::File->new(
        auth => $self->user_auth,
        id => $file_id
    );
    $file->download;
}

=pod

B<delete_file($self,$file_id)>

    Deletes the file corresponding to the given file_id.
    Returns true if successful, false otherwise.

=cut

sub delete_file {
    my ($self,$file_id) = @_;
    $self->authenticate_user;
    my $file = Storage::Box::File->new(
        auth => $self->user_auth,
        id => $file_id
    );
    $file->delete;
}

=pod

B<create_folder($self,$name)>

    Creates a folder with the given name and returns
    the folder id.  The parent of this folder is '0'
    by default.  Setting the 'parent' property on the
    folder object allows you to specify a different
    parent object.  This function returns the folder_id
    for the newly created folder.

=cut

sub create_folder {
    my ($self,$name) = @_;
    $self->authenticate_user;
    my $folder = Storage::Box::Folder->new(
        auth => $self->user_auth,
        name => $name
    );
    $folder->create;
}
=pod

B<list_folder($self,$folder_id)>
    
    Returns an array of hashes representing the files and folders
    contained by the folder with the given folder_id.

=cut

sub list_folder {
    my ($self,$folder_id) = @_;
    $self->authenticate_user;
    my $folder = Storage::Box::Folder->new(
        auth => $self->user_auth,
        folder_id => $folder_id
    );
    $folder->items;
}

=pod

B<delete_folder($self,$folder_id)>

    Deletes the folder corresponding to the given folder_id.
    Returns true if successful, and false otherwise.

=cut

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

Copyright (C) 2016 Dave Goehrig

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut

1;


