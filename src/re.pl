$topic_research_aspects = "(Researchers |Research ).*?(is concerned with |are concerned with |((have | has )(addressed |proposed |observed |investigated |focused on |looked at )))";

$topic_literature_review = "(literature |literature review |prior work )(covered |dealt with |focused on covers |deals with |looks at |focuses on |on |in )";

$topic_areas_research = "((research |studies |findings )in the (field |area |domain |context )of)|(The emergence of)";

$whom_did_study = "(recent)? (work |study |research ).*(was (introduced |described |devised |developed |proposed |explored ))?by";

$research_motivation = "((The |Our |Their )underlying research (question |objective |intention )(was |is ))|((solution |in order )to)";

$hypothesis = "(argue|argues|argued|hold|holds|holded|debate|debates|debated|believe|believes|believed) that";

##conduct, explore, propose, pursue, describe, attemp to, represent, analyze, axamine, investigate

$objectives = "conducted|conducts|explored|explores|proposed|proposes|pursued|pursues|described|describes|attempted to|attempts to|reprsented|represents|analyzed|analyzes|examined|examines|investigated|investigates|deals with|dealed with|seeks to discover|seeked to discover";

## find, claim, argue, establish, identify, show, conclude, contend, report, assert, demonstrate reveal, observe, point out, opine, infer, state,perceived, evidence, illustrate 

## research result
$research_found = "(found|claimed|detected|argued|established|identified|showed|concluded|contended|reported|confirmed|asserted|demonstrated|revealed|observed|pointed out|opined|inferred|stated|perceived|evidenced|yielded|illustrated|highlighted) that";

## system performance
$system_performance = "performance|improvement"

##specific system or model
$aim_of_system_or_model = "(system |model )(of|to|for|in)";
$details_of_system_or_model = "(system |model )(using |uses)";

## describe research method
$experiment = "(survey |experiment |approach |methods |method |techniques |methodologies )(conducted )?(of|to|for|in)";

## general conclusion
$conclusion = "(results of|findings of|picture presented by|consensus)"

##evaluation
$evalutaion = "(evaluate|evaluated|test|tested|measure|measured|assess|assessed|rank|judge|judged|judgement)";

$target = "For example, the National Center for Education Statistics (Heaviside, Farris, Dunn, & Fry, 1995) conducted a survey of libraries in which the libraries estimated that 60% of their users were youth";







while ($target =~ /$experiment/gmi){
    print "^^";
}


