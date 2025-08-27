using { task.manager as my } from '../db/schema';

/** ein Service für alle Rollen: Praktikant, Mitarbeiter, Chef */
service ProcessorService @(requires: 'authenticated-user') {
  @odata.draft.enabled
  @cds.redirection.target

  // --- Tasks ---
  @restrict: [
    // Praktikant: nur lesen und Status ändern
    { grant: ['READ','UPDATE'], to: 'praktikant' },
    // Mitarbeiter: alle CRUD-Operationen
    { grant: ['READ','CREATE','UPDATE','DELETE'], to: 'mitarbeiter' },
    // Chef: alles
    { grant: '*', to: 'chef' }
  ]
  entity Tasks as projection on my.Tasks;

  // --- Comments ---
  @restrict: [
    // Praktikant: lesen + schreiben
    { grant: ['READ','CREATE'], to: 'praktikant' },
    // Mitarbeiter: nur lesen
    { grant: ['READ'], to: 'mitarbeiter' },
    // Chef: alles
    { grant: '*', to: 'chef' }
  ]
  entity Comments as projection on my.Comments;

  // --- Status ---
  @restrict: [
    { grant: ['READ'], to: ['praktikant','mitarbeiter','chef'] }
  ]
  entity Status as projection on my.Status;

  // --- Urgency ---
  @restrict: [
    { grant: ['READ'], to: ['praktikant','mitarbeiter','chef'] }
  ]
  entity Urgency as projection on my.Urgency;
  
}