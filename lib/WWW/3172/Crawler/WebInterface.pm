package WWW::3172::Crawler::WebInterface;
use Dancer ':syntax';
use Dancer::Plugin::DataFu;
#use Template;
use WWW::3172::Crawler;
use HTML::Entities qw(encode_entities);
use Data::Table;
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
        my $crawl_data = $crawler->crawl;
 
        my $headers = ['URL', 'Keywords', 'Description', 'Size (bytes)', 'Speed (s)'];
        my @rows;
        while (my ($url, $data) = each %$crawl_data) {
            delete $crawl_data->{$url};
            my $data = [
                "<a href='$url'>" . encode_entities($url) . "</a>",
                $data->{keywords},
                $data->{description},
                $data->{size},
                sprintf("%.5f", $data->{speed}),
            ];
            push @rows, $data;
        }
        my $table = Data::Table->new(\@rows, $headers, 0);

        return template 'table.tt', { table => $table->html };
    }
    redirect '/';
};

true;

