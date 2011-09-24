package WWW::3172::Crawler::WebInterface;
use Dancer ':syntax';
use Dancer::Plugin::DataFu;
#use Template;
use WWW::3172::Crawler;
use HTML::Entities;
# ABSTRACT: Provides a web frontend to WWW::3172::Crawler
# VERSION

get '/' => sub {
    return template 'index.tt', { form => form->render('crawl', '/submit_crawl', 'crawl.url', 'crawl.max') };
};

post '/submit_crawl' => sub {
    my $input = form;
    if ($input->validate('crawl.url', 'crawl.max')) {
        my $crawler = WWW::3172::Crawler->new(
            host    => $input->params->{'crawl.url'},
            max     => $input->params->{'crawl.max'},
        );
        my $data = $crawler->crawl;
        my $table = '';
        foreach my $url (keys %$data) {
            no warnings 'uninitialized';
            my $safe_url = encode_entities($url);
            my $keywords = encode_entities($data->{$url}->{keywords});
            my $description = encode_entities($data->{$url}->{description});
            my $safe_size   = encode_entities($data->{$url}->{size});
            my $safe_speed  = encode_entities(sprintf("%.5f", $data->{$url}->{speed}));

            $table .= <<"TABLE";
<tr>
    <td><a href="$safe_url">$safe_url</a></td>
    <td>$keywords</td>
    <td>$description</td>
    <td>$safe_size</td>
    <td>$safe_speed</td>
</tr>
TABLE
        }

        return template 'table.tt', { table => $table };
    }
    redirect '/';
};

true;

