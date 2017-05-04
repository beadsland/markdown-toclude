'use babel';

import SrcView from './src-view';
import { CompositeDisposable } from 'atom';

export default {

  srcView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.srcView = new SrcView(state.srcViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.srcView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'src:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.srcView.destroy();
  },

  serialize() {
    return {
      srcViewState: this.srcView.serialize()
    };
  },

  toggle() {
    console.log('Src was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
