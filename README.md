# NAME

Storage::Box - a module for managing storage at Box.com

# SYNOPSIS

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

# DESCRIPTION

Storage::Box is module for interfacing with Box.com's REST API.
It provides a JWT authenticated cleint for a server side application.

# METHODS

**authenticate\_enterprise($self)**

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

**authenticate\_user($self)**

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

**create\_user($self,$name)**

    Creates a new Box.com App user with the given username.
    If successful it will set the user object's id to the
    user's user_id.

**read\_user($self,$user\_id)**

    Reads a user object for the given user_id,
    returns a hash with the user's data.
    On failure it will return an empty hash.

**update\_user($self,$user\_id,%options)**

    Updates a user object specified by user_id with the given hash 
    of key => values. Returns the updated user hash.

**delete\_user($self,$user\_id)**

    Deletes the user associated with $user_id.  Returns true on success.

**create\_file($self,$filename)**

    Uploads the file specified by filename,
    and returns the file object.  If the 
    file is successfully uploaded the id 
    of the file object willl be set.

**download\_file($self,$file\_id)**

    Returns the contents of the file specified by file_id,
    or an empty string if it fails.

**delete\_file($self,$file\_id)**

    Deletes the file corresponding to the given file_id.
    Returns true if successful, false otherwise.

**create\_folder($self,$name)**

    Creates a folder with the given name and returns
    the folder id.  The parent of this folder is '0'
    by default.  Setting the 'parent' property on the
    folder object allows you to specify a different
    parent object.  This function returns the folder_id
    for the newly created folder.

**list\_folder($self,$folder\_id)**

    Returns an array of hashes representing the files and folders
    contained by the folder with the given folder_id.

**delete\_folder($self,$folder\_id)**

    Deletes the folder corresponding to the given folder_id.
    Returns true if successful, and false otherwise.

# AUTHOR

Dave Goehrig <dave@dloh.org>

# COPYRIGHT

Copyright 2016- Dave Goehrig

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
