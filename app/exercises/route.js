import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.findAll('exercise');
  },
  setupController(model, controller) {
    this._super(model, controller);
    this.controller.set(
      'exercises', Ember.computed.filterBy('model', 'isNew', false));
  }
});
