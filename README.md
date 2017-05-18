markdown-toclude
=======

Atom extension to transclude list items into markdown files

Status
======

This extension, when complete, will provide for transclusion of list items into markdown files from arbitrary sources, with an option to truncate such lists when appropriate.

The goal is to allow for prepending TODO lists across related projects, such that a single master task list can be used as an overall project plan.

Presently, it only knows how to transclude the top five list items from a local (relative path) markdown file.

Usage
-----

Markdown-toclude may be used to transclude items from any number of sources. (For now, only local markdown files are supported as sources.) Each source to be transcluded is identified using a `TOCLUDE` comment, as follows:

```html
<!-- TOCLUDE: name: *TAG* target: *CLUDEME.md* -->
```

In the above example, we've instructed markdown-toclude to transclude lines from the file `CLUDEME.md` in the same local directory as the transcluding file, and insert those lines within the [comment block](#comment-block-syntax) named `TAG`.

Currently, markdown-toclude will process all `TOCLUDE` comments, and update associated blocks, on the hotkey <kbd>ctrl</kbd>\-<kbd>alt</kbd>\-<kbd>o</kbd>. This will eventually be replaced by a before-save event handler, but this is still prerelease code.

Markdown-toclude will seek an existing comment block of the name given, and replace its contents if found. If not found, it will insert a new block with that name immediately before the first top-level list item not, itself, enclosed in a comment block (*i.e.*, the first list item not presumably managed by markdown-toclude or another plugin). If no top-level list items are found in the including file, the new comment block will be inserted immediately following the last comment (ignoring [`TRASH`](#garbage-collection)) found in the file.

Comment Block Syntax
--------------------

Markdown-toclude inserts transcluded content within an HTML comment block, like so:

```html
<!-- TAG -->

- first transcluded line
- second transcluded line
- ...

<!-- /TAG -->
```

To avoid clobbering itself or other plugins that mutate markdown documents, markdown-toclude insists that only well-formed comment blocks be present in the transcluding markdown file. The following conditions will raise errors:
* **orphan**: A closing comment is found without a matching open comment.
* **trailing**: A closing comment is followed by its matching open comment.
* **non-unique**: A closing comment is repeated or has more than one matching open comment.
* **overlap**: A closing comment from one comment block appears within another comment block.

On the other hand, if markdown-toclude finds the opening comment of a named comment block, but no matching closing comment, it will append the matching closing comment and raise a warning. This may happen if a block closing comment is mistakenly deleted from a file, in which case, previously transcluded lines may need to be cleaned up, having being left outside the newly reformed block.

Garbage Collection
------------------

Markdown-toclude replaces the contents of comment blocks named in `TOCLUDE` comments each time it updates transcluded lines. To protect against user-provided content mistakenly inserted with a comment block being automagically banished to oblivion, markdown-toclude maintains a `TRASH` comment at the end of the markdown file. The last 25 unique lines deleted from any markdown-toclude comment block (and not presently included among the most recently transcluded lines) are retained in the `TRASH` comment for safekeeping.

License
=======

"markdown-toclude" is copyright © 2017 Beads Land-Trujillo.

Markdown-toclude source code is released under MIT License.

Check [NOTICE](NOTICE.md) and [LICENSE](LICENSE.md) files for more information.
