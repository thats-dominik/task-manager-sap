using { task.manager as my } from '../db/schema';

/** worker: lesen + status ändern; kommentare schreiben */
service TaskWorkerService @(requires: ['worker']) {
  @odata.draft.enabled
  @cds.redirection.target

  @restrict: [
    { grant: ['READ','UPDATE'], to: 'worker' },
    { grant: '*',               to: 'admin' }   // admin darf alles hier
  ]
  entity Tasks    as projection on my.Tasks;

  @restrict: [
    { grant: ['READ','CREATE'], to: 'worker' },
    { grant: '*',               to: 'admin' }
  ]
  entity Comments as projection on my.Comments;

  @readonly entity Status  as projection on my.Status;
  @readonly entity Urgency as projection on my.Urgency;
}

/** giver: aufgaben anlegen/bearbeiten; kommentare lesen */
service TaskGiverService @(requires: 'giver') {
  @odata.draft.enabled
  @cds.redirection.target

  @restrict: [
    { grant: ['READ','CREATE','UPDATE','DELETE'], to: 'giver' },
    { grant: '*',                                  to: 'admin' }
  ]
  entity Tasks    as projection on my.Tasks;

  @restrict: [
    { grant: ['READ'], to: 'giver' },
    { grant: '*',      to: 'admin' }
  ]
  entity Comments as projection on my.Comments;

  @readonly entity Status  as projection on my.Status;
  @readonly entity Urgency as projection on my.Urgency;
}

/** admin: alles */
service AdminService @(requires: 'admin') {
  entity Tasks    as projection on my.Tasks;
  entity Comments as projection on my.Comments;
  entity Status   as projection on my.Status;
  entity Urgency  as projection on my.Urgency;
}
