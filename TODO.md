TODO
====

Prep for insertion of block if not found
========================================

-	refactor
-	one func return array of all non-block passages
-	one func return array of all TOCLUDE comment instruction tags

Prep for insertion of transcluded content
=========================================

-	find first list item in non-block
-	find specified block
-	if specified block not found, find open tag for our block
-	if found only open tag, insert close tag
-	if didn't find our block insert before first comment
-	find trash comment, append if not found
-	garbage collect trash comment
-	move contents of our block to trash comment
-	insert dummy lines to our block
-	if our block empty, remove it (this ought to be optional)

Transclusion rules
==================

-	iterate over transclusion rule comments
-	block name option
-	transclude source: local, target: relative path
-	preserve empty block option
-	truncation option
-	ignore target comment block option
-	transclude github issues
-	transclude github pull requests
-	incorporate in master project
