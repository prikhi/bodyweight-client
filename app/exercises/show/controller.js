import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    delete() {
      this.get('model').destroyRecord().
        then(() => {
          this.transitionToRoute('exercises');
        });
    }
  }
});
