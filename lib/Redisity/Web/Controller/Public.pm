use strict;
use warnings;

package Redisity::Web::Controller::Public {
    use Mojo::Base 'Mojolicious::Controller';
    use MIME::Base64 qw/encode_base64 decode_base64/;
    use experimental qw/postderef signatures/;
    use JSON::MaybeXS;

    has json => sub { state $json = JSON::MaybeXS->new(utf8 => 0) };

    sub home($self) {
        $self->render(hej => time);
    }

    sub scan($self) {
        my @keys = ();
        my $cursor = 0;
        my $new_keys = [];

        while(1) {
            $new_keys = [];
            ($cursor, $new_keys) = $self->redis->actual->scan($cursor);
            push @keys => $new_keys->@*;
            last if $cursor == 0;
        }

        $self->render(json => [map { { key => decode_base64($_), actual_key => $_ } } @keys]);
    }

    sub command($self) {
        my $command = $self->param('command');
        my $keys = $self->every_param('keys[]');

        my $data = [];
        for my $key (@$keys) {
            if($command eq 'TTL') {
                push @$data => { key => $key, ttl => $self->redis->actual->ttl($key) };
            }
        }
        $self->render(json => { keys => $data });
    }

    sub delete_key($self) {
        my $key = $self->param('key');

        my $result = $self->redis->actual->del($key);

        $self->render(json => { result => $result });
    }

    sub get_key_value($self) {
        my $key = $self->param('key');

        $self->render_json({ value => $self->redis->actual->get($key) }, 1);
    }

    sub render_json($self, $data, $pretty = 0) {
        if($pretty) {
            $self->render(data => $self->json->pretty(1)->encode($data), format => 'json');
        }
        else {
            $self->render(data => $self->json->encode($data), format => 'json');
        }
    }

}

1;


__END__
