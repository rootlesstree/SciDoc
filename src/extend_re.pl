#!/usr/bin/perl
#use warnings;
#use strict;

#execute the program as perl extend_re.pl 1 3 2 4 DOC_NAME, the first
#three numbers indicate the enlarge, shrink of the graph weight and
#the last one is the change of lexrank score
# Fourth number indicates the length of the summary 
# And the last one is the sentence list 
use Clair::Cluster;
use Clair::Document;
use Clair::Network::CFNetwork;
use Clair::Network::Centrality::LexRank;
use Clair::Network::Centrality::Betweenness;

my %categories = ();
my %in_community = ();

$id = 0;


$enlarge = shift;
$shrink = shift;
$multiply = shift;
#print $enlarge,$shrink,$multiply;
#$enlarge = 2;
#$shrink = 2;
#$multiply = 4;


sub getFileName{
    my $file = shift;
    my @temp = split(/\//, $file);
    my $name = $temp[$#temp];
    @temp = split(/\./, $name);
    $name = $temp[0];
    return $name;
}


# Check which pattern the target belongs to
sub category {

    if ($_[0] =~ /$topic_research_aspects/gmi) { return "topic"; }
    elsif ($_[0] =~ /$topic_literature_review/gmi){ return "topic";}
    elsif ($_[0] =~ /$topic_areas_research/gmi){return "topic";}
    elsif ($_[0] =~ /$whom_did_study/gmi){ return "topic";}
    elsif ($_[0] =~ /$research_motivation/gmi){ return "topic";}
    elsif ($_[0] =~ /$hypothesis/gmi){ return "method";}
    elsif ($_[0] =~ /$objectives/gmi){ return "method";}
    elsif ($_[0] =~ /$research_found/gmi){ return "result";}
    elsif ($_[0] =~ /$system_performance/gmi){ return "result";}
    elsif ($_[0] =~ /$aim_of_system_or_model/gmi){ return "method";}
    elsif ($_[0] =~ /$details_of_system_or_model/gmi){ return "method";}
    elsif ($_[0] =~ /$experiment/gmi) {  return "method";}
    elsif ($_[0] =~ /$conclusion/gmi) {  return "result";}
    elsif ($_[0] =~ /$evaluation/gmi) {  return "evaluation";}
    else { 
        my $string;
        for (0..7) { $string .= chr (int(rand(25) + 65));}
            return $string; }
 

}



sub check_community{
    my ($sent1,$sent2) = @_;
#    print $sent1,category($sent1),"\n";
    if (category($sent1) eq category($sent2))
    {  #print "something\n";
        #print category($sent1),"\n";
        if($in_community{$sent1} != 1){
        print category($sent1),": ","\n",$sent1,"\n";
        }
        $in_community{$sent1} = 1;
        return $enlarge;
    }
    else {

        return $shrink;}

}






###
### TOPIC RELATED
###

$topic_research_aspects = "(Researchers |Research ).*?(is concerned with |are concerned with |((have | has )(addressed |proposed |observed |investigated |focused on |looked at )))"; # A.1.1

$topic_literature_review = "(literature |literature review |work )(covered |dealt with |focused on covers |deals with |looks at |focuses on |on |in )"; #A.1.2

$topic_areas_research = "((research |studies |findings )in the (field |area |domain |context )of)|(The emergence of)"; # A.1.3

$whom_did_study = "(recent)? (work |study |research )?.*(was (introduced |described |devised |developed |proposed |explored ))?by"; # B.1.1

$research_motivation = "((The |Our |Their )underlying research (question |objective |intention )(was |is ))|((solution |in order )to)"; # B.1.2


###
### RESULT RELATED STATEMENT
###

## research result
$research_found = "(found|claimed|detected|argued|established|identified|showed|concluded|contended|reported|confirmed|asserted|demonstrated|revealed|observed|pointed out|opined|inferred|stated|perceived|evidenced|yielded|illustrated|highlighted) that"; # B.8.1

## system performance
$system_performance = "( reported | report| showed | show| exhibited | exhibit).*(performance|improvement)"; #B.8.2

## general conclusion
$conclusion = "(results of|findings of|picture presented by|consensus)"; # C.3.1


###
### METHODS
###


$hypothesis = "(argue|argues|argued|hold|holds|holded|debate|debates|debated|believe|believes|believed) that";  #B.2.3

$objectives = " conducted | conduct| explored | explore| proposed | propose| pursued | pursue| described | describe| attempted to| attempt(s)? to| reprsented | represent| analyzed | analyze| examined | examine| investigated | investigate| deal(s)? with | dealed with | seek(s)? to discover | seeked to discover | developed | develope |Using |Used"; # B.1.1
##specific system or model

$aim_of_system_or_model = "(system |model )(of|to|for|in)";  #B.4.1
$details_of_system_or_model = "(system |model )(using |uses\b )"; #B.4.2

## describe research method
$experiment = "(survey |experiment |approach |methods |method |techniques |methodologies )(conducted )?(of|to|for|in)"; # B.5.1



###
### EVALUTAIION
###

$evaluation = " (evaluate |evaluated |test |tested |measure |measures|measured |assess |assessed |ranked |judge |judged |judgement )"; # B.6.2




my $limit = shift;
my $file = shift;
my $cutoff = 0.0;

my $name = &getFileName($file);

my %sents = ();
my %origSents =();
my $id = 0;
my @files = ();
push(@files, $file);

for my $file (@files){    
    open IN, "$file";    
    while(<IN>){
        chomp $_;
        my $orig = $_;
        my $l = $_;
        $l = lc($l);
        $l =~ s/\([^\)]+\)/ /g;
        $l =~ s/\[[^\]]+\]/ /g;
        $l =~ s/\s+/ /g;
        ++$id;
        $sents{$id} =  $l;
        $origSents{$id} = $orig;
    }
}




my $totalsents = keys %sents;

foreach my $key (keys %sents) {

}

my $test = <STDIN>;
if($totalsents <= 3)
{
    my $summary = "";
    for my $i (keys %sents)
    {
        $summary = $summary . $origSents{$i}."\n";
    }
    open OUT, ">outputs/".$name."-C-LR.txt";
    print OUT "$summary";
    print $summary;
    exit;
}


my $cluster = Clair::Cluster->new();
for my $id (keys %sents){
    my $sent = $sents{$id};
    my $doc = new Clair::Document(type => 'text', string => $sent, id => $id);
    $cluster->insert($id, $doc);
}

$cluster->stem_all_documents();
my %sims = $cluster->compute_cosine_matrix();


my %nodes = ();
my $cfnw = Clair::Network::CFNetwork->new(name => $name); 

for my $s1 (keys %sents){
    for my $s2 (keys %sents){
        my $sim = $sims{$s1}{$s2};
        ##
        ## process regular expression here
        ##
        $sim = check_community($sents{$s1},$sents{$s2})*$sim;
        
        if($sim >= $cutoff){
            $cfnw->add_weighted_edge($s1, $s2, $sim);
        }
    }
}

my $subcfnw = $cfnw->getConnectedComponent(1);
$subcfnw->communityFind(dirname => "temp", skip_connection_test => 1);

my %communities = ();
my %comsize = ();
if(-e "temp/".$name.".bestComm")
{
    open IN, "temp/".$name.".bestComm";
    while(<IN>){
        chomp $_;
        my @arr = split(/ /, $_);
        my $id = $arr[0];
        my $comm = $arr[1];
        if(! exists $comsize{$comm}){
            $comsize{$comm} = 1;
        }else{
            $comsize{$comm} = $comsize{$comm} +1 ;
        }
        $communities{$comm}{$id} = 1; 
    }
}else
{
    for my $i(keys %sents)
    {
        my $comm = 1;
        if(! exists $comsize{$comm}){
            $comsize{$comm} = 1;
        }else{
            $comsize{$comm} = $comsize{$comm} +1 ;
        }
        $communities{$comm}{$i} = 1; 
    }
}



#for my $com (keys %communities) {
#    
#    for my $id (keys %{$communities{$com}}){
#
#        my $sent = $sents{$id};
#        print "$sent\n"
#    }

#    print "\n\n\n\n\n"
#}





my %commLexRank = ();

for my $com (keys %communities){
    my $comcluster = Clair::Cluster->new();
    for my $id (keys %{$communities{$com}}){
        my $sent = $sents{$id};
        my $doc = new Clair::Document(type => 'text', string => $sent, id => $id);
        $comcluster->insert($id, $doc);
    }
    my %scores = $comcluster->compute_lexrank(cutoff=>0.1);

    ## Try to let the lexrank score of matched sentence higher

    for my $t (keys %scores){
        if(exists $in_community{$sents{$t}}){
            $scores{$t} = $scores{$t}*$multiply;
        }
    }

    for my $t (sort {$scores{$b}<=> $scores{$a}} keys %scores){
        $commLexRank{$com}{$t} = $scores{$t};

    }
}



for my $com (keys %communities) {

    for my $id (keys %{$communities{$com}}){

        my $sent = $sents{$id}."  ".$commLexRank{$com}{$id};
        print "$sent\n"


    }

    print "\n\n\n\n\n"
}












my %rankedSents = ();
my $i = 0;
for my $comm (sort {$comsize{$b} <=> $comsize{$a}} keys %comsize){
    ++$i;
    my $j = 0;
    for my $id (sort {$commLexRank{$comm}{$b} <=> $commLexRank{$comm}{$a}} keys %{$commLexRank{$comm}}){
        ++$j;
        my $sent = $origSents{$id};
        $rankedSents{$j}{$i} = $sent; 
    }
}

my $numorigSents = keys %sents;
if($numorigSents < $limit)
{
    $limit = $numorigSents;
}

my $summary = "";
my $count = 0;


print "\n\n\n\n\n";
for my $t (keys %in_community){
    print $t,"\n";
}

print "\n\n\n\n\n";




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

open OUT, ">outputs/".$name."-C-LR.txt";
print OUT "$summary";
print "$summary";

close OUT;
