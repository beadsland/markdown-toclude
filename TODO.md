TODO
====

Housekeeping
============

-	omit template code
-	review licensing
-	refactor activation

Prep for insertion of block if not found
========================================

-	refactor (former) constants to package context
-	take text as parameter
-	refactor test to blocks
-	find block close comments
-	error on duplicate close comments
-	find close block open comments
-	error on duplicate open comments
-	error on trailing open comments
-	error on no open comment
-	one func return array of all comment blocks
-	one func return array of all non-block comment tags
-	one func return array of all non-block passages

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
