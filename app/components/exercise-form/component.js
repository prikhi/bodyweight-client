import Ember from 'ember';

export default Ember.Component.extend({
  isEditing: Ember.computed.or('model.isNew', 'editingToggled'),
  editingToggled: false,
});
