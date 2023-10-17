CLASS zcl_vat_validate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_vat_validate IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TRY.
        out->write( lcl_vat_validate=>create( )->run( 'LU26375245' ) ).
      CATCH cx_root INTO DATA(exc).
        out->write( exc->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
