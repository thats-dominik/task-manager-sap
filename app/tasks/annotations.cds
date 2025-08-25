/******************************************************************************
 * annotations.cds – vollständige UI-Annotationen für alle drei Services
 * - worker  (TaskWorkerService / Rolle: support)
 * - giver   (TaskGiverService  / Rolle: giver)
 * - admin   (AdminService      / Rolle: admin)
 *
 * Grundsatz:
 * - UI-Struktur (Facets, LineItem, HeaderInfo, FieldGroups) wird EINMAL auf
 *   dem Basismodell (my.*) definiert und gilt für alle Projektionen.
 * - Service-spezifische Bearbeitbarkeit erfolgt über FieldControl:
 *   - worker: nur status_code editierbar, alle anderen Felder read-only
 *   - giver : status_code read-only, alle anderen Felder editierbar
 *   - admin : alles editierbar (keine FieldControl-Restriktionen)
 ******************************************************************************/

using { task.manager as my } from '../../db/schema';
using TaskWorkerService as worker from '../../srv/services';
using TaskGiverService  as giver  from '../../srv/services';
using AdminService      as admin  from '../../srv/services';

/* =========================
   Gemeinsame UI für Tasks
   ========================= */
annotate my.Tasks with @(
  UI.FieldGroup #GeneratedGroup : {
    $Type : 'UI.FieldGroupType',
    Data  : [
      { $Type : 'UI.DataField', Value : title,       Label : '{i18n>Title}' },
      { $Type : 'UI.DataField', Value : description, Label : '{i18n>Description1}' },
      { $Type : 'UI.DataField', Value : dueDate,     Label : '{i18n>DueDate}' }
    ]
  },

  UI.Facets : [
    {
      $Type  : 'UI.CollectionFacet',
      Label  : '{i18n>Overview}',
      ID     : 'i18nOverview',
      Facets : [
        {
          $Type  : 'UI.ReferenceFacet',
          ID     : 'GeneratedFacet1',
          Label  : '{i18n>GeneralInformation}',
          Target : '@UI.FieldGroup#GeneratedGroup'
        },
        {
          $Type  : 'UI.ReferenceFacet',
          Label  : '{i18n>Details}',
          ID     : 'i18nDetails',
          Target : '@UI.FieldGroup#i18nDetails'
        }
      ]
    },
    {
      $Type  : 'UI.ReferenceFacet',
      Label  : '{i18n>Comments}',
      ID     : 'i18nComments',
      Target : 'comments/@UI.LineItem#i18nComments'
    }
  ],

  UI.LineItem : [
    { $Type : 'UI.DataField', Value : title,         Label : '{i18n>Title}' },
    { $Type : 'UI.DataField', Value : description,   Label : '{i18n>Description1}' },
    { $Type : 'UI.DataField', Value : dueDate,       Label : '{i18n>DueDate}' },
    { $Type : 'UI.DataField', Value : status.descr,  Label : '{i18n>Status}',   Criticality : status.criticality },
    { $Type : 'UI.DataField', Value : urgency.descr, Label : '{i18n>Urgency}' }
  ],

  UI.SelectionFields : [ status_code, urgency_code ],

  UI.HeaderInfo : {
    Title :          { $Type : 'UI.DataField', Value : title },
    TypeName :       '',
    TypeNamePlural : '',
    Description :    { $Type : 'UI.DataField', Value : description },
    TypeImageUrl :   'sap-icon://alert'
  },

  UI.FieldGroup #i18nDetails : {
    $Type : 'UI.FieldGroupType',
    Data  : [
      { $Type : 'UI.DataField', Value : status_code },
      { $Type : 'UI.DataField', Value : urgency_code }
    ]
  }
);

/* ValueHelp/Text für Status/Urgency (einheitlich für alle Services) */
annotate my.Tasks with {
  status @(
    Common.Label : '{i18n>Status}',
    Common.ValueListWithFixedValues : true,
    Common.Text : status.descr,
    Common.ExternalID : status.descr
  );
  urgency @(
    Common.Label : '{i18n>Urgency}',
    Common.ValueListWithFixedValues : true,
    Common.Text : urgency.descr,
    Common.ExternalID : urgency.descr
  );
};

/* ===========================
   Gemeinsame UI für Comments
   =========================== */
annotate my.Comments with @(
  UI.LineItem #i18nComments : [
    { $Type : 'UI.DataField', Value : message,   Label : '{i18n>Message}' },
    { $Type : 'UI.DataField', Value : createdAt },
    { $Type : 'UI.DataField', Value : createdBy }
  ]
);

/* ======================================================
   Service-spezifische FieldControl (Bearbeitbarkeit)
   ====================================================== */

/* --------- WORKER (support): nur Status änderbar --------- */
/* Tasks: title/description/dueDate/urgency_code read-only, status_code editierbar */
annotate worker.Tasks with {
  title        @Common.FieldControl : #ReadOnly;
  description  @Common.FieldControl : #ReadOnly;
  dueDate      @Common.FieldControl : #ReadOnly;
  urgency_code @Common.FieldControl : #ReadOnly;
  /* status_code absichtlich ohne ReadOnly → editierbar für Worker */
};

/* Comments: Worker darf Kommentare anlegen → keine ReadOnly-Flags notwendig */
annotate worker.Comments with {};

/* --------- GIVER (giver): Status NICHT änderbar, Rest editierbar --------- */
annotate giver.Tasks with {
  status_code @Common.FieldControl : #ReadOnly;
  /* alle übrigen Felder editierbar */
};

/* Comments: Giver darf Kommentare anlegen → keine ReadOnly-Flags notwendig */
annotate giver.Comments with {};

/* --------- ADMIN (admin): alles editierbar --------- */
/* Keine FieldControl-Restriktionen nötig */
annotate admin.Tasks with {};
annotate admin.Comments with {};

/* ======================================================================================
   Hinweis:
   - Schreibrechte werden technisch in services.cds via @restrict/@requires durchgesetzt.
   - Diese FieldControl-Anmerkungen steuern NUR die UI-Bearbeitbarkeit pro Service.
   - Serverseitig zusätzlich absichern (empfohlen): Handler validieren verbotene Feldupdates.
   ====================================================================================== */
