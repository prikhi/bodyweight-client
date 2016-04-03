import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('exercise', {
      name: "",
      description: "",
      isHold: false,
      youtubeIds: "",
      amazonIds: "",
      copyright: ""
    });
  },
});
