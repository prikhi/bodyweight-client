import DS from 'ember-data';

export default DS.Model.extend({
  order: DS.attr('number'),
  section: DS.attr('section'),
  exercises: DS.hasMany('exercise'),
  setCount: DS.attr('number'),
  repCount: DS.attr('number'),
  restAfter: DS.attr('boolean')
});
