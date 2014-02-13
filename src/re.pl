#!/usr/bin/perl
#use warnings;
#use strict;

use Clair::Cluster;
use Clair::Document;
use Clair::Network::CFNetwork;
use Clair::Network::Centrality::LexRank;
use Clair::Network::Centrality::Betweenness;

my %categories = ();

$id = 0;




$topic_research_aspects = "(Researchers |Research ).*?(is concerned with |are concerned with |((have | has )(addressed |proposed |observed |investigated |focused on |looked at )))";

$topic_literature_review = "(literature |literature review |prior work )(covered |dealt with |focused on covers |deals with |looks at |focuses on |on |in )";

$topic_areas_research = "((research |studies |findings )in the (field |area |domain |context )of)|(The emergence of)";

## this is my own version 
$whom_did_study = "(recent)? (work |study |research )?.*(was (introduced |described |devised |developed |proposed |explored ))?by";

$research_motivation = "((The |Our |Their )underlying research (question |objective |intention )(was |is ))|((solution |in order )to)";

$hypothesis = "(argue|argues|argued|hold|holds|holded|debate|debates|debated|believe|believes|believed) that";

##conduct, explore, propose, pursue, describe, attemp to, represent, analyze, axamine, investigate

$objectives = "conducted|conducts|explored|explores|proposed|proposes|pursued|pursues|described|describes|attempted to|attempts to|reprsented|represents|analyzed|analyzes|examined|examines|investigated|investigates|deals with|dealed with|seeks to discover|seeked to discover";

## find, claim, argue, establish, identify, show, conclude, contend, report, assert, demonstrate reveal, observe, point out, opine, infer, state,perceived, evidence, illustrate 

## research result
$research_found = "(found|claimed|detected|argued|established|identified|showed|concluded|contended|reported|confirmed|asserted|demonstrated|revealed|observed|pointed out|opined|inferred|stated|perceived|evidenced|yielded|illustrated|highlighted) that";

## system performance
$system_performance = "performance|improvement";

##specific system or model
$aim_of_system_or_model = "(system |model )(of|to|for|in)";
$details_of_system_or_model = "(system |model )(using |uses)";

## describe research method
$experiment = "(survey |experiment |approach |methods |method |techniques |methodologies )(conducted )?(of|to|for|in)";

## general conclusion
$conclusion = "(results of|findings of|picture presented by|consensus)";

##evaluation
$evaluation = " (evaluate|evaluated|test|tested|measure|measured|assess|assessed|ranked|judge|judged|judgement)";

my %origSents = ();
$id = 0;
sub category {

    if ($_[0] =~ /$topic_research_aspects/gmi) {$categories{"topic_research_aspects"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$topic_literature_review/gmi){$categories{"topic_literature_review"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$topic_areas_research/gmi){$categories{"topic_areas_research"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$whom_did_study/gmi){$categories{"whom_did_study"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$research_motivation/gmi){$categories{"research_motivation"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$hypothesis/gmi){$categories{"hypothesis"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$objectives/gmi){$categories{"objectives"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$research_found/gmi){$categories{"research_found"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$system_performance/gmi){$categories{"system_performance"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$aim_of_system_or_model/gmi){$categories{"$aim_of_system_or_model"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$details_of_system_or_model/gmi){$categories{"details_of_system_or_model"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$experiment/gmi) {$categories{"experiment"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$conclusion/gmi) {$categories{"conclusion"}{$id++} = $_[0]; }
    elsif ($_[0] =~ /$evaluation/gmi) {$categories{"evaluation"}{$id++} = $_[0]; }
    else {$categories{"No Category"}{$id++} = $_[0]; }
    
    $origSents{$id} = $_[0];
}



open(OUT,"../docs/citing_sentences_list/C08-1122.list") || die $!;



while(<OUT>){
    category $_;
}

my %comsize = ();
my %commLexRank = ();

for my $com (keys %categories) {

    if ($com eq "No Category"){next;}

    my $comcluster = Clair::Cluster->new();

    for my $id (keys $categories{$com}){

        if (! exists $comsize{$com}) {
            $comsize{$com} = 1;        }
        else{ $comsize{$com} = $comsize{$com} + 1;}

        my $sent = $categories{$com}{$id};
        my $doc = new Clair::Document(type => 'text', string => $sent, id => $id);
        $comcluster->insert($id, $doc); 
    }   
    my %scores = $comcluster->compute_lexrank(cutoff=>0.1);

    for my $t (sort {$scores{$b} <=> $scores{$a}} keys %scores){
        $commLexRank{$com}{$t} = $scores{$t};
}
}

my %rankedSents = ();
my $i = 0;

for my $comm (sort {$comsize{$b} <=> $comsize{$a}} keys %comsize){
    ++$i;
    my $j = 0;
    for my $id (sort {$commLexRank{$comm}{$b} <=> $commLexRank{$comm}{$a}} keys $commLexRank{$comm}){
        ++$j;
        my $sent = $origSents{$id};
        $rankedSents{$j}{$i} = $sent;
}
}

my $summary = "";
my $count = 0;
$limit = 4;

for my $jj (sort {$a<=>$b} keys %rankedSents)
{
    for my $ii (sort {$rankedSents{$a}<=>$rankedSents{$b}} keys %{$rankedSents{$jj}})
    {
        ++$count;
        $summary = $summary.$rankedSents{$jj}{$ii}."\n";
        if($count == $limit)
        {
            last;
        }
    }
    if($count == $limit)
    {
        last;
    }
}

print $summary;
=begin

for my $category (keys %categories)
{   print $category," ------>\n";

    for my $keys (keys $categories{$category}){
    print $categories{$category}{$keys},"\n";
    }
}

=end
=cut

#while ($target =~ /$experiment/gmi){
#    print "^^";
#}


