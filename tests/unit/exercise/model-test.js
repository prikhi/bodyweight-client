import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';

moduleForModel('exercise', 'Unit | Model | exercise', {
  // Specify the other units that are required for this test.
  needs: []
});

test('it exists', function(assert) {
  let model = this.subject();
  // let store = this.store();
  assert.ok(!!model);
});

test('the type is correct', function(assert) {
  let model = this.subject();
  model.isHold = true;
  assert.equal(model.get('type'), 'Hold');
  Ember.set(model, 'isHold', false);
  assert.equal(model.get('type'), 'Reps');
});
