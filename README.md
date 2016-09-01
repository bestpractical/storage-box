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

Storage::Box is 

# METHODS

**create\_user($self,$name)**

    Creates a new Box.com App user with the given username

**read\_user($self,$user\_id)**

    Reads a user object for the given user_id

**update\_user($self,$user\_id,%options)**

    Updates a user object specified by user_id with the given hash 
    of key => values. Returns the updated user object.

**delete\_user($self,$user\_id)**

    Deletes the user associated with $user_id.  Returns true on success.

**create\_file($self,$filename)**

# AUTHOR

Dave Goehrig <dave@dloh.org>

# COPYRIGHT

Copyright 2016- Dave Goehrig

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
