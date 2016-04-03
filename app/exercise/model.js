import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  description: DS.attr('string'),
  isHold: DS.attr('boolean'),
  youtubeIds: DS.attr('string'),
  amazonIds: DS.attr('string'),
  copyright: DS.attr('string'),

  type: Ember.computed('isHold', function() {
    if (this.get('isHold')) {
      return 'Hold';
    }

    return 'Reps';
  })

});
