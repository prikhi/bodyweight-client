import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  routine: DS.belongsTo('routine', { async: true }),
  sectionExercises: DS.hasMany('sectionExercise', { async: true })
});
