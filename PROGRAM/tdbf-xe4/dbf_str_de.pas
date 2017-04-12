unit dbf_str;

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Oeffnen: Datei nicht gefunden: "%s"';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Datensatz gesperrt.';
  STRING_WRITE_ERROR                  := 'Schreibfehler: Speicherplatz kontrollieren';
  STRING_WRITE_INDEX_ERROR            := 'Schreibfehler; Indizes wahrscheinlich beschädigt. (Speicherplatz kontrollieren)';
  STRING_KEY_VIOLATION                := 'Index-Zugriffsverletzung: Indexschluessel bereits vorhanden.'+#13+#10+
                                         'Index: %s'+#13+#10+'Record=%d Schlüssel=''%s''';

  STRING_INVALID_DBF_FILE             := 'Ungueltige DBF-Datei.';
  STRING_FIELD_TOO_LONG               := 'Wert ist zu lang: %d Zeichen (maximal erlaubt: %d).';
  STRING_INVALID_FIELD_COUNT          := 'Ungueltige Anzahl von Feldern: %d (muss zwischen 1 und 4095 sein).';
  STRING_INVALID_FIELD_TYPE           := 'Feldtyp ''%s'' ist ungültig für das Feld ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Feld "%s" kann nicht erzeugt werden: VCL-Feldtyp %x wird nicht von DBF unterstuetzt.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Index basiert auf unbekanntem Feld "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Feld "%s" hat ungueltigen Feldtyp für einen Index.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Das Ergebnis des Index-Ausdrucks "%s" ist zu lang, >100 Zeichen (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Ungültiger Indextyp: nur Zeichen oder Numerisch erlaubt.';
  STRING_CANNOT_OPEN_INDEX            := 'Oeffnen des Index ist gescheitert: "%s".';
  STRING_TOO_MANY_INDEXES             := 'Zufuegen eines weiteren Index nicht moeglich: zu viele Indizes in der Datei.';
  STRING_INDEX_NOT_EXIST              := 'Index "%s" existiert nicht.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Exclusivzugriff fuer diese Aktion noetig.';
end.

