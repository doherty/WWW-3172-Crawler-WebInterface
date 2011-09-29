package WWW::3172::Crawler::WebInterface;
use Dancer ':syntax';
use Dancer::Plugin::DataFu;
#use Template;
use WWW::3172::Crawler;
use List::UtilsBy qw(nsort_by);
use HTML::Entities qw(encode_entities);
use Data::Table;
# ABSTRACT: Provides a web frontend to WWW::3172::Crawler
# VERSION

our $imported_crawler;
sub import {
    $imported_crawler = $_[1];
}

get '/' => sub {
    return template 'index.tt', { form => form->render('crawl', '/submit_crawl', 'crawl.url', 'crawl.max') };
};

post '/submit_crawl' => sub {
    my $input = form;
    if ($input->validate('crawl.url', 'crawl.max')) {
        my $crawler = $imported_crawler || WWW::3172::Crawler->new(
            host    => $input->params->{'crawl.url'},
            max     => $input->params->{'crawl.max'},
        );
        my $crawl_data = $crawler->crawl;

        return template 'table.tt', {
            main_table  => _main_table($crawl_data),
            stats_table => _stats_table($crawl_data),
        };
    }
    redirect '/';
};

sub _main_table {
    my $crawl_data = shift;

    my $headers = ['URL', 'Keywords', 'Description', 'Size (bytes)', 'Speed (s)'];
    my @rows;
    while (my ($url, $data) = each %$crawl_data) {
        push @rows, [
            "<a href='$url'>" . encode_entities($url) . "</a>",
            $data->{keywords},
            $data->{description},
            $data->{size},
            sprintf("%.5f", $data->{speed}),
        ];
    }
    return Data::Table->new(\@rows, $headers, 0)->html;
}

sub _stats_table {
    my $crawl_data = shift;
    my %keywords;

    while (my ($url, $data) = each %$crawl_data) {
        my @these_keywords = split /,\s?|\s+/, ($data->{keywords} || '');
        $keywords{$_}++ for @these_keywords;
    }
    return '' if keys %keywords == 0;

    my $html = '<ul><li>';
    $html .= join '</li><li>', map { encode_entities($_) }
        nsort_by { $keywords{$_} } keys %keywords;
    $html .= '</li></ul>';

    return $html;
}

true;

