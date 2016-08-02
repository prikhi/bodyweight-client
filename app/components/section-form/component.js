import Ember from 'ember';

export default Ember.Component.extend({
  isEditing: Ember.computed.or('model.isNew', 'editingToggled'),
  editingToggled: false,

  toggleEditing() {
    this.toggleProperty('editingToggled');
  },
  cancelSection() {
    this.get('model').rollbackAttributes();
  },
  deleteSection() {
    this.get('model.exercises').then((exercises) => {
      exercises.forEach((exercise) => {
        exercise.destroyRecord();
      });
    });
  },
  actions: {
    deleteSection() {
      this.get('model').destroyRecord();
    },
    newExercise() {
      let model = this.get('model');

      if (model.get('isNew')) {
        if (model.get('name') !== '') {
          this.set('errorMessage', '');
          model.save().then(() => {
            this.set('editingToggled', true);
            this.sendAction('addExercise', model);
          });
        } else {
          this.set('errorMessage',
                  'You must first enter a name for the Section.');
        }
      } else {
        this.sendAction('addExercise', this.get('model'));
      }
    },
  },
});
