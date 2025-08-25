using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

namespace task.manager;

/**
 * zentrale aufgaben-entity
 */
entity Tasks : cuid, managed {
  title        : String          @title : 'title';     // aufgabentitel
  description  : String;                                 // optional
  dueDate      : Date            @title : 'due date';  // abgabe-/fälligkeitsdatum
  urgency      : Association to Urgency default 'M';   // H/M/L
  status       : Association to Status  default 'O';   // open/.../done
  comments     : Composition of many Comments on comments.task = $self;
}

/**
 * kommentare zu aufgaben (verlauf)
 */
entity Comments : cuid, managed {
  task     : Association to Tasks;
  message  : String;
}

/**
 * status-codelist
 */
entity Status : CodeList {
  key code : String enum {
    open        = 'O';
    in_progress = 'I';
    blocked     = 'B';
    done        = 'D';
  };
  criticality : Integer; // optional für fiori-darstellung (ampel)
}

/**
 * urgency-codelist
 */
entity Urgency : CodeList {
  key code : String enum {
    high   = 'H';
    medium = 'M';
    low    = 'L';
  };
}
