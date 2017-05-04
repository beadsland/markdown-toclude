'use babel';

/* eslint vars-on-top: "off" */
/* eslint no-cond-assign: ["error", "except-parens"] */

/* global atom */
import { CompositeDisposable } from 'atom'; // eslint-disable-line

// import request from 'request'

export default {

  subscriptions: null,

  activate() {
    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'sourcefetch:fetch': () => this.fetch(),
    }));
  },

  deactivate() {
    this.subscriptions.dispose();
  },


// event listener: onWillSave

  ctag: RegExp(/^\s+?-\s/, 'm'),

//  ctag: RegExp(/^\s+?-\s/, 'm'),
//  ctag: RegExp(/let editor\s+?if/, 'g'),
//  ctag: RegExp(/^((?!let editor\s+?if).)*$/, 'm'),
//  ctag: RegExp('^((?![\s\S]let editor[\s\S]).)*$'),
  found: false,

  fetch() {
    const log = atom.notifications;

    log.addInfo('sourcefetch:toggle');

    const editor = atom.workspace.getActiveTextEditor();
    if (editor) {
      const text = editor.getBuffer().getText();

      /* eslint no-unused-vars: "warn" */
      const oCom = '<!--\\s';
      const cCom = '\\s-->';
      const ComTag = '(\\w+)';
      const oComTag = `${ComTag}[\\w\\s\\:]*?`;
      const cComTag = `/${ComTag}`;
      const pattern = oCom + oComTag + cCom;
//      const re = RegExp(oCom + cComTag + cCom);

      if (RegExp(pattern).test(text)) {
        const re = RegExp(pattern, 'g');
        let m;
        while ((m = re.exec(text)) !== null) {
          log.addInfo(`found: ${m[1]}`);
        }
      } else {
        log.addWarning('no array');
      }
    }
    // search for all <!-- \
    // find ranges that the above closes
    // find remaining ranges
    // search remaining ranges for first list line
    // get position of start of first list line
    // insert before that


/*    let editor
    if (editor = atom.workspace.getActiveTextEditor()) {
      let scope
      scope = editor.getGrammar().scopeName
      atom.notifications.addInfo(scope)

//      editor.scan(this.ctag, this.found_ctag)
      text = editor.getBuffer().getText()
//      arry = text.match(this.ctag)
      if (this.ctag.test(text)) { atom.notifications.addWarning('exists') }
      else { atom.notifications.addSuccess('does not exist') }
//      atom.notifications.addSuccess(arry[0])
*/
  },

};
