import Ember from 'ember';

export default Ember.Controller.extend({
  addSection() {
    this.get('model.sections').then((sections) => {
      sections.addObject(this.store.createRecord('section', { name: "" }));
    });
  },
  actions: {
    newSection() {
      let model = this.get('model');

      if (model.get('isNew')) {
        if (model.get('name') !== '') {
          this.set('errorMessage', '');
          model.save().then(() => {
            this.addSection();
          });
        } else {
          this.set('errorMessage',
                   'You must first enter a name for the Routine.');
        }
      } else {
        this.addSection();
      }
    },
    saveRoutine() {
      this.get('model').save().then(() => {
        this.transitionToRoute('routines.show', this.get('model.id'));
      });
    },
    addExercise(section) {
      section.get('sectionExercises').then((exercises) => {
        exercises.addObject(this.store.createRecord('sectionExercise'));
      });
    },
  }
});
